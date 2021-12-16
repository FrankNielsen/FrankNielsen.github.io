// ------------------------------------------------------------------------
// This program is complementary material for the book:
//
// Frank Nielsen
//
// Visual Computing: Geometry, Graphics, and Vision
//
// ISBN: 1-58450-427-7
//
// Charles River Media, Inc.
//
//
// All programs are available at http://www.charlesriver.com/visualcomputing/
//
// You may use this program for ACADEMIC and PERSONAL purposes ONLY. 
//
//
// The use of this program in a commercial product requires EXPLICITLY
// written permission from the author. The author is NOT responsible or 
// liable for damage or loss that may be caused by the use of this program. 
//
// Copyright (c) 2005. Frank Nielsen. All rights reserved.
// ------------------------------------------------------------------------
 
// ------------------------------------------------------------------------
// File: priorityqueue-stl.cpp
// 
// Description: Priority queues in C++ STL
// ------------------
#include "stdafx.h"

#include <iostream>
#include <queue>

using namespace std;

void main(void)
{
priority_queue<int>  q;


cout<<"Visual Computing: Geometry, Graphics, and Vision (ISBN:1-58450-427-7)"<<endl;
cout<<"Demo program\n\n"<<endl;


cout<<"First, I add 100 integer numbers randomly."<<endl;

 	// Insert random items in the priority queue
    for(int i=0;i<100;i++)
    	q.push(rand()%1000);
    	

cout<<"Then I retrieve those numbers one by one from the priority queue."<<endl;

   	// Get the sorted list in decreasing order
    while (!q.empty()) 
    	{cout << q.top() << " "; q.pop();}

char line[256];
cout<<"\n\nPress Return"<<endl;
gets(line);
}

