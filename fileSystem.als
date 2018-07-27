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
