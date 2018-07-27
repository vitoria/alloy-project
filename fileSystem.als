module FilesSystem

/*
ESPECIFICAÇÃO
Um determinado sistema operacional define três níveis de permissão para diretórios e arquivos (objetos): Leitura, Leitura/Escrita e Dono. 
O dono é o único que pode modificar a permissão de um objeto. Cada uma das seguintes categorias de usuários possui um nível de permissão 
para cada objeto: Todos, Externos, Usuários deste Computador. 
Por exemplo, um arquivo file.txt pode ter permissão de dono para Usuários deste Computador, permissão de Leitura/Escrita para 
usuários Externos, e Leitura Para Todos. Diretórios podem conter outros diretórios e arquivos (a pasta Root é a pasta superior de todas as outras). 
Um arquivo ou diretório nunca podem ter, para uma determinada categoria de usuários, uma permissão menos restrita do que um 
diretório ancestral dele.
*/

some sig Computer {
	root: one Root,
	users: some User
}

/*
 ----------------------- Object ---------------------
 Objeto que possui um mapeando entre o usuário e o tipo de permissão.
*/
abstract sig Object {
	permissions: User -> one Permission
}

// Arquivo que é um tipo de Objeto.
sig Archive extends Object{}

// Diretório é um tipo de objeto que contém um conjunto de outros objetos.
abstract sig Directory extends Object{
	objects: set Object
}
/*
 Root é um tipo de diretório que representa o diretório raiz de um computador.
 CommonDirectory representa todos os diretórios de um computador que não seja o Root.
*/
sig Root, CommonDirectory extends Directory{}

/*
 ------------------- Permission ------------------
 Permissão representa uma permissão
*/
abstract sig Permission {}

// Read é um tipo de permissão que possibilida apenas a leitura de um objeto
one sig Read extends Permission {}

// Write é um tipo de permissão que possibilita leitura e escrita de um objeto
one sig Write extends Permission {}

// Admin é um tipo de permissão que possibilita leitura, escrita e alterar os tipos de permissão.
one sig Admin extends Permission {}

/*
------------------------ User -----------------------
Usuário é uma entidade do sistema que representa um usuário externo ou um usuário local
em relacao a cada objeto, dependendo apenas do computador ao qual esse usuário pertence.
*/
sig User{}

/*
 -------------------------- Fatos --------------------------
 Todo diretório não pode conter ele mesmo no seu conjunto de objetos.
*/
fact DirectoryNoContainsHimself{
	all d:Directory | d !in d.^objects
}

// Todo objeto deve pertencer a um diretório, exceto quando é um Root.
fact AllObjectsNotRootHaveOneParentDirectory{
	all o: Object | (o !in Root) => (one d: Directory | o in d.objects) else (no d: Directory | o in d.objects)
}

// Todo objeto deve ser filho direta ou indiretamente de um root.
fact OneRootAncestral{
	all o:Object | one r: Root | o in r.*objects
}

// Cada computador deve conter apenas um root distinto dos demais computadores.
fact RootInOneComputer {
	all r: Root | one c:Computer | r in c.root
}

// Cada usuário deve pertencer a apenas um computador.
fact UserInOneComputer {
	all u: User | one c:Computer | u in c.users
}

// Para cada usuário do mesmo tipo (local ou externo)  deve ter o mesmo tipo de permissão para cada objeto.
fact allUsersFromSameTypeWithSamePermission {
	all o:Object | all p:Permission |	all u:User | all u':User |
	localUsersWithSamePermission[o, p, u, u'] && externalUsersWithSamePermission[o, p, u, u']
}

// Para cada objeto filho de um determinado diretório, ele deve ter um tipo de permissão equivalente ou mais restrita que o seu pai.
fact noLessRestrictivePermissionInMoreRestrictiveDirectory {
	all o:Object | all u:User | all p:Permission |
	(u -> p in o.permissions) => (
	(p in Write => one r:Read |  u -> r !in o.^objects.permissions) &&
	(p in Admin => (one r:Read |  u -> r !in o.^objects.permissions) && (one w:Write |  u -> w !in o.^objects.permissions))
	)
}

// Todo objeto deve ter pelo menos um usuário como administrador.
fact eachObjectShouldHaveAtLeastOneAdminUser {
	all o:Object | one a:Admin | some u:User | u -> a in o.permissions
}

// Predicado que verifica se dois usuários locais têm o mesmo tipo de permissão em um determinado objeto.
pred localUsersWithSamePermission[o:Object, p:Permission, u:User, u':User] {
	(u in getComputerFromObject[o].users && u' in getComputerFromObject[o].users) =>
	(u -> p in o.permissions => u' -> p in o.permissions)
}
