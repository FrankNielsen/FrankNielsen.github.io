int n = 16;
int k = 5;

// This produces n!/(n−k)! tuples instead of n^k

int nbsubsets=0;

void setup() {
  int[] tuple = new int[k];
  boolean[] used = new boolean[n + 1];

  generateTuples(tuple, 0, used);
  
  println("number of k tuples:"+nbsubsets);
  exit();
}

void generateTuples(int[] tuple, int position, boolean[] used) {

  if (position == tuple.length) {
    //printTuple(tuple);
    nbsubsets++;
    return;
  }

  for (int x = 1; x <= n; x++) {
    if (!used[x]) {
      used[x] = true;
      tuple[position] = x;

      generateTuples(tuple, position + 1, used);

      used[x] = false;  // backtrack
    }
  }
}

void printTuple(int[] tuple) {
  print("(");
  for (int i = 0; i < tuple.length; i++) {
    print(tuple[i]);
    if (i < tuple.length - 1) print(", ");
  }
  println(")");
}
