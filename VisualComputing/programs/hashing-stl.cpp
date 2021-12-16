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
// File: hashing-stl.cpp
// 
// Description: 1D hashing using C++ STL
// ------------------------------------------------------------------------

#include "stdafx.h"
#include <iostream>
#include <hash_map>
using namespace std;

hash_map <const char *, int> room;

void main(void) 
{

cout<<"Visual Computing: Geometry, Graphics, and Vision (ISBN:1-58450-427-7)"<<endl;
cout<<"Demo program\n\n"<<endl;

cout<<"I hash a few names (name, room number), and access room[somebody] where somebody is a string type."<<endl;

room["Frank"] = 423;
room["Paul"] = 402;
room["Shigeru"] = 309;
room["Henry"] = 305;

cout << "Paul's room is " << room["Paul"]<< "."<<endl;

cout<<"\n\nCollisions are not accepted here."<<endl;

char line[256];
cout <<"\nPress Return key"<<endl;
gets(line);
}