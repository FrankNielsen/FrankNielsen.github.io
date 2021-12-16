#include <mpi.h>
#include <iostream>
#include <vector>
#include <bitset>
#include <cstdio>
#include <cstdlib>
using namespace std;


class Gray{
public:
  vector <int> code(int n){
    vector <int> v;
    v.push_back(0);
    for(int i=0; i < n; i++){
      int h = 1 << i; // 100000 with i zeros
      int len = v.size();
      for(int j = len-1;j>=0;j--){
	v.push_back(h+v[j]);
      }
    }
    return v;
  }
};

int lowest_non_zero_bit(int order, int code){ 
// we take the convention from the course, that the lowest nonzero bit of 0 is 1 << i where i == "order of the gray code"

  if(code == 0)
    return order;
  else{
    int temp = code;
    int i=0;
    while(temp % 2 == 0){
      i++;
      temp = temp / 2;
    }
    return i;
  }
}

vector<int> neighbours(int order, int code){
  vector<int> res;
  int lnz = lowest_non_zero_bit(order,code);
  if (lnz==0)
    return res;
  else{
    for(int i=0;i<lnz;i++){
      res.push_back(code + (1 << (lnz-1-i)));
    }
    return res;
  }
}

vector<int> reverse_lookup(vector<int> * graycode){
  int n = graycode->size();
  vector<int> res(n);
  for(int i=0;i<n;i++){
    res[(*graycode)[i]]=i;
  }
  return res;
}

int main(int argc, char * argv[]){
  int rank,size,order;
  MPI_Status status ;
  MPI_Init (& argc , & argv ) ;
  MPI_Comm_rank ( MPI_COMM_WORLD , &rank ) ;
  MPI_Comm_size ( MPI_COMM_WORLD , &size ) ;
  
  order=0;
  while((1 << order) < size){
    order++;
  }
  Gray g;
  vector<int> toGray = g.code(order);
  vector<int> fromGray = reverse_lookup(&toGray); 
  // we build a reverse lookup table from the Gray codes of all nodes so as to be able to retrieve their actual rank in constant time
  
  
  if (rank==0){
    int value = rand() % 1001;
    printf("I am process 0 and am now sending out the value %d\n",value);
    vector<int> rootNeighbors = neighbours(order,0);
    for(int i=0;i< rootNeighbors.size();i++){  
      int neighbRank = fromGray[rootNeighbors[i]]; 
	  // we retrieve the actual rank of the current neighbour from its Gray code
      if (neighbRank<size){ 
	  // remember we "rounded up" to the smallest hypercube containing all nodes, so we need to check this is an actual neighbor
	printf("process %d: my current neighbor is %d\n",rank,neighbRank);
	MPI_Send(&value,1,MPI_INT,neighbRank,0,MPI_COMM_WORLD);
      }
    }
  }
  else{
    int grayRank = toGray[rank];
    int lnb = lowest_non_zero_bit(order,grayRank);
    int grayPredecessor = (grayRank - (1 << lnb)); 
    int predecessor = fromGray[grayPredecessor];
    cout << "I am process " << rank << " of gray code " << (bitset<8>) grayRank << " and I am waiting for a message from my predecessor in the binomial tree " << predecessor << endl;
    int received_value;
    MPI_Recv(&received_value,1,MPI_INT,predecessor,0,MPI_COMM_WORLD,&status);
    vector<int> rootNeighbors = neighbours(order,grayRank);
    if (rootNeighbors.size() == 0){
      cout <<  "I am process " <<  rank << " of gray code " << (bitset<8>) grayRank <<   " and I have no descendants, so I will stop here!" << endl;
    }
    else{
      
      cout << "I am process " <<  rank << " of gray code " << (bitset<8>) grayRank <<   " and am now sending out the value " << received_value << " to my neighbors "<<  endl;
      for(int i=0;i< rootNeighbors.size();i++){  
	int neighbRank = fromGray[rootNeighbors[i]]; // we retrieve the actual rank of the current neighbour from its Gray code
	if (neighbRank<size){ 
	  // remember we "rounded up" to the smallest hypercube containing all nodes, so we need to check this is an actual neighbor
	  MPI_Send(&received_value,1,MPI_INT,neighbRank,0,MPI_COMM_WORLD);
	}
      }
    } 
  }
  MPI_Finalize();
  return 0;
}