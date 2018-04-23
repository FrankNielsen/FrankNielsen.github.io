class node
{
  double x, y;
  String label;

  node(double xx, double yy, String ll)
  {
    x=xx;
    y=yy;
    label=ll;
  }
}

class graph
{
  int n;
  node [] tabnode;
  boolean [][] adjacency;

  public String toString()
  {
    String res="";
    res=nbNode()+" "+nbEdge()+"\n";
    int i, j;
    String val;

    for (i=0; i<n; i++) {
      for (j=0; j<n; j++) 
      {
        if (adjacency[i][j]==true) val="1"; 
        else val="0"; 
        res=res+val+" ";
      }
      res=res+"\n";
    }
    return res;
  }

  graph duplicate()
  {
    graph result;
    int i, j;

    result=new graph(n);
    for (i=0; i<n; i++) {
      result.tabnode[i]=new node(tabnode[i].x, tabnode[i].y, tabnode[i].label);
    }

    for (i=0; i<n; i++) {
      for (j=0; j<n; j++) 
      {
        result.adjacency[i][j]=adjacency[i][j];
      }
    }
    return result;
  }

  graph(int nn)
  {
    n=nn;
    tabnode=new node[n];
    adjacency=new boolean[n][n];
  }

  double nbNode() {
    return n;
  }

  double nbEdge()
  {
    double res=0;
    int i, j;

    for (i=0; i<n; i++)
      for (j=i+1; j<n; j++)
      {
        if (adjacency[i][j]) 
        {
          res+=1.0;
        }
      }
    return res;
  }

  double density()
  {
    if (n==0) return 0; 
    else  
      return (double)nbEdge()/(double)nbNode();
  }

  int selectMinDeg() {
    if (n>0) return argmin(degree());
    else return -1;
  } 

  int argmin(int [] tab)
  {
    int winner=0; 
    int min=tab[0];
    int i;
    for (i=1; i<n; i++) {
      if (tab[i]<min) {
        winner=i; 
        min=tab[i];
      }
    }
    return winner;
  }

  int [] degree()
  {
    int [] res=new int[n];
    int i, j, nb;
    for (i=0; i<n; i++)
    {
      nb=0;

      for (j=0; j<n; j++) 
      {
        if (adjacency[i][j]) nb++;
      }

      res[i]=nb;
    }
    return res;
  }

  // remove only one node: nodes
  graph subgraph(int nodes)
  {
    graph result=new graph(n-1);
    int nb=0;
    int i, j;

    for (i=0; i<n; i++)
    {
      if (i!=nodes) result.tabnode[nb++]=tabnode[i];
    }

    for (i=0; i<n; i++)
      for (j=0; j<n; j++)
      {
        if ((i<nodes)&&(j<nodes)) result.adjacency[i][j]=adjacency[i][j];
        if ((i<nodes)&&(j>nodes)) result.adjacency[i][j-1]=adjacency[i][j];
        if ((i>nodes)&&(j<nodes)) result.adjacency[i-1][j]=adjacency[i][j];
        if ((i>nodes)&&(j>nodes)) result.adjacency[i-1][j-1]=adjacency[i][j];
      }
    return result;
  }

  // Get a subgraph from the current graph
  graph subgraph(boolean [] remove)
  {
    int i, j;
    int nr=0;
    for (i=0; i<remove.length; i++)
      if (remove[i]) nr++;

    int nkeep=n-nr;
    graph result=new graph(nkeep);

    nkeep=0;
    for (i=0; i<n; i++)
    {
      if (!remove[i]) 
      {
        result.tabnode[nkeep++]=tabnode[i];
      }
    }

    int [] label=new int[n];
    int ll=-1;

    for (i=0; i<n; i++)
    {
      if (!remove[i]) {
        ll++;
      }

      label[i]=ll;
    }

    result.adjacency=new boolean[nkeep][nkeep];

    for (i=0; i<n; i++)
      for (j=0; j<n; j++)
      {
        if  ((!remove[i])&&(!remove[j]))
          result.adjacency[label[i]][label[j]]=adjacency[i][j];
      }
    return result;
  }

  // return the best density graph
  graph denseSubgraph()
  {
    int i;
    double bestd=density(), currentd;
    graph G, bestG;
    int nodes;
    G=this.duplicate();
    bestG=this.duplicate();

    for (i=0; i<n; i++)
    {
      nodes=G.selectMinDeg();
      G=G.subgraph(nodes);
      currentd=G.density();
      if (currentd>bestd) {
        bestd=currentd; 
        bestG=G.duplicate();
      }
    }
    return bestG;
  }
}

