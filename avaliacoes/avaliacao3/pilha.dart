import 'dart:collection';

void main(){
  Queue<String> pilha = Queue();
  pilha.addAll(["Vitão", "Davi", "Fernando", "Renan", "Alex"]);

  void verTopo (Queue fila) {
  print(fila.last);
  }

  void removerTopo (Queue fila) {
    fila.removeFirst();
  }

  void adicionarTopo(Queue fila, String nome) {
    fila.addFirst(nome);
  }

  void imprimirFila (Queue fila) {
    print(fila);
  }
  
  verTopo(pilha);
  removerTopo(pilha);
  adicionarTopo(pilha, "Joao");
  imprimirFila(pilha);

}