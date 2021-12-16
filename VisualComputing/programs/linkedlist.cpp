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
// File: linkedlist.cpp
// 
// Description: Simple templated linked list class
// ------------------------------------------------------------------------

#include "stdafx.h"


template <class T> class LinkedList
{
public:
	T element;
	LinkedList<T>  *next;

	// Create an empty list 
	// (In fact, a single element with a NULL successor pointer)
	LinkedList<T>() {next=NULL;}

	void addElement(T e)
	{element=e;
	next=new LinkedList<T>();}

	// Linear Search
	bool isMember(T e)
	{
	LinkedList<T> * pos=this;
	while(pos->next!=NULL)
	{if (e==pos->element) return true;
	pos=pos->next;}
	return false;
	}
};

#include <stdio.h>
using namespace std;

class LinkedListInt
{
public:
	int element;
	LinkedListInt  *next;

	// Create an empty list 
	// (In fact, a single element with a NULL successor pointer)
	LinkedListInt() {next=NULL;}

	void addElement(int e)
	{element=e;
	next=new LinkedListInt();}

	// Element membership in linear time
	bool isMember(int e)
	{LinkedListInt * pos=this;
	
	while(pos->next!=NULL)
	{if (e==pos->element) return true;
	pos=pos->next;}

	return false;}
};


int _tmain(int argc, _TCHAR* argv[])
{
int i;

cout<<"Visual Computing: Geometry, Graphics, and Vision (ISBN:1-58450-427-7)"<<endl;
cout<<"Demo program\n\n"<<endl;


LinkedListInt *list, *head;


list=new LinkedListInt;
head=list;

cout<<"I add the first 10 integer elements to the list."<<endl;
for(i=0;i<10;i++)
{
list->addElement(i);
list=list->next;
}

cout <<"Singly Connected Linked List Demo:"<<endl<<endl;
cout << "Membership(0) ? " << head->isMember(0) <<endl;
cout << "Membership(5) ? " << head->isMember(5) <<endl;
cout << "Membership(9) ? " << head->isMember(9) <<endl;
cout << "Membership(15) ? " << head->isMember(15) <<endl;

char line[256];
cout<<"Press Return key"<<endl;
gets(line);

return 0;
}

