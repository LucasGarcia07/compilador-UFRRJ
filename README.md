# Conteúdo
## Comandos de Laço (for, while e do/while)
### for
  for(int i = 0; i <= 10; i++){
    for(int j = 0; j <= 10; j++){
      int d = i + j;
    }
  }

### while
  int i = 0;
  while(i < 10){
    int j = 0;
  }

### do while
  int i = 0;
  do{
    int j = 0;
  } while(i < 10);

## Comandos de Decisão
### if, else, elif
  int a = 0;
  
  if(a == 0){
    print("aaa");
  } elif( a == 1){
    print("bbb");
  } else{
    print("ccc");
  }

### switch
  int a = 0;

  switch(a){
    case 1{
      int b = 10;
      break;
    }
    case 0{
      int b = 20;
      break;
    }
  }
  
## Operadores Aritméticos
  int expression = 10 + 100 * (6 / 3) - 10;

## Operadores Relacionais (gerando boolean)
  int a = 10;
  int b = 5;
  bool c = a > b;
  bool d = a < b;
  bool e = a >= b;
  bool f = a <= b;
  bool g = a == b;

## Operadores Lógicos (gerando boolean)
  bool a = true and false;
  bool a = true or false;
  bool a = not false;

## Operadores Compostos
  int a = 10;
  a += 1;
  a -= 1;
  a *= 1;
  a /= 1;

## Operadores Unários
  int a = 10;
  a++;
  a--;
  a = -a;

## Conversão de Tipos
  int a = (int) 10.0;

## Mecanismos de Controle de Laços
  for(int i = 0; i <= 10; i++){
    for(int j = 0; j <= 10; j++){
      if(i > j){
        break;
      } elif(j > i){
        continue;
      }
    }
  }

## Escopo global
  for(int i = 0; i <= 10; i++){
    for(int j = 0; j <= 10; j++){
      global int d = i + j;
    }
  }
  print(d);

## Concatenação de String
  string a = "aa" + "bb";

## Matriz
  int a[10][10];
  a[1][1] = 1;

## Expressões Condicionais
  int a = 10;
  int b = 5;
  int c = 0;
  c = (a > b) ? a b;

## Comandos de Entrada e Saída
  read("aa");
  print("bb");

## Subprograma
  Não implementado