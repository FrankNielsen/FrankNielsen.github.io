// filename: OddEvenSort.cpp
void OddEvenSort(int a[], int n)
{
  int phase, i;
  for (phase = 0; phase < n; phase++)
    if (phase % 2 == 0)
		 {// even stage
      for (i = 1; i < n; i += 2)
        {if (a[i-1] > a[i])
          swap(&a[i], &a[i-1]);}
			}
    else 
     {// odd stage
				for (i = 1; i < n-1; i += 2)
          {if (a[i] > a[i+1])
            swap(&a[i], &a[i+1]);}
		 }
}