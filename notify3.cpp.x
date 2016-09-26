#include <iostream>
#include <cstring>
#include <fstream>
#include <vector>
#include <sstream>
#include <algorithm>
using namespace std;


struct noticeType
{
    string person;
    string subject;
    vector<string> message; // contains array of messages
    noticeType *link;
};

//helperfunction
string removefromcommaspacedelimitedstring(const string tempMessage, const vector<string> smessage)
{
    string newstring;
    
    return newstring;
}
class linkedlisttype
{
private:
    //add private elements
    noticeType *first;
    noticeType *last;
    int count;

public:  
    //defaultconstructor
    linkedlisttype()
    {
         first=NULL;
         last=NULL;
         count=0;
    }
    ~linkedlisttype()
    {
        //destroyList();
    }

    noticeType *gethead()
    {
        return first;
    }
    int getcount()
    {
        return count;
    }
    //destroy the list
    void destroyList()
    {
        noticeType *temp; 
        while (first != NULL) 
        {
            temp = first;
            first = first->link; 
            delete temp; 
        }
        last = NULL;
        count = 0;
    }
    void print() const
    {
        noticeType *current; 
        current = first; 
        while (current != NULL) 
        {
        cout << current->person << "\t"<<current->subject << "\t" ;
        //vector<string> temp;
        for (size_t i = 0; i < (current->message).size(); i++)
        {
            if (i>0)
                cout << ", ";
            cout << (current->message)[i];
        }
        cout << endl;
        current = current->link;
        }
    }    
    string tostring() const
    {
        string liststring = "";
        noticeType *current; 
        current = first; 
        while (current != NULL) 
        {
        //cout << current->person << "\t"<<current->subject << "\t" ;
        liststring += current->person+"\t"+current->subject+"\t";
        //vector<string> temp;
        for (size_t i = 0; i < (current->message).size(); i++)
        {
            if (i>0)
                //cout << ", ";
                liststring +=", ";
            //cout << (current->message)[i];
            liststring+=current->message[i];
        }
        //cout << endl;
        liststring += "\n";
        current = current->link;
        }
        return liststring;
    }
    void additem_workflow(const string person, const string subject, const string message)
    {
        //check if subject contains "-cancellation" or "(cancelled)"
        bool iscancellation;
        bool iscancelled;
        string strip_cancelled, strip_cancellation;
        if (subject.length()>13)
        {
            string data = subject.substr(subject.length()-13,13);
            transform(data.begin(), data.end(), data.begin(), ::tolower);
            if (data=="-cancellation")
            {
                iscancellation = true;
                strip_cancellation = subject.substr(0,subject.length()-13);
            }
        }
        if (subject.length()>11)
        {
            string data = subject.substr(subject.length()-11,11);
            transform(data.begin(), data.end(), data.begin(), ::tolower);
            if (data=="(cancelled)")
            {
                iscancelled = true;
                strip_cancelled = subject.substr(0,subject.length()-11);
            }
        }
        // MAIN PROCESSING
        //1. is item a duplicate --- ignore
        if (searchDuplicateExist(person, subject, message))
        {
            //ignore;
        }
        //2. is item a "(cancelled)" notice --- remove existing notice
        else if(iscancelled && strip_cancelled == "Approve-reservation")
        {
            removecancelledmessageitem(person, strip_cancelled, message); //person & updated subject must match, remove message that match
            removeItemsemptymessages();

        }
        //2. is item a "-cancellation" notice --- remove prior notices and revised notices, even if different person
        else if(iscancellation && strip_cancellation == "Purchase-order")
        {
            //cout << "strip_cancellation = " << strip_cancellation <<endl;
            removecancellationmessageitem(person, "Approve-purchase-order", message);// updated subject must match, remove message that match
            string revise_string = strip_cancellation + "-revise";
            removecancellationmessageitem(person, revise_string, message);
            removeItemsemptymessages();
        }
        //3. if there is already an Item with same person and subject append to existing item body
        else if (searchPersonSubjectExists(person,  subject, message))
        {
            //add code to append to existing item
            appendtoexistingItem(person,  subject, message);
        }
        //4. else if item is new, add new nodetype object
        else 
        {
            addNewItemtoback(person, subject, message);
        }
    }
    void removecancelledmessageitem(const string rperson, const string rsubject, const string rmessage)
    {
        //person & updated subject must match, remove message that match
        //similar to search duplicate
        //if (rperson == "Amelia" ) {cout << "in amelia  cancelled " << rsubject<< endl;}
        noticeType *current; //pointer to traverse the list
        bool found = false;
        current = first; //set current to point to the first node in the list
        while (current != NULL && !found)
        {
            bool messageexists = find((current->message).begin(), (current->message).end(), rmessage) != (current->message).end();
            if ( current->person == rperson && current->subject == rsubject && messageexists) //searchItem is found
            {
                //cout << endl;
                //cout << "initial current message: ";
                vector<string> updatedmessage;
                for (size_t i = 0; i < (current->message).size(); i++)
                {
                    //cout << (current->message)[i]<< " ";
                    if ((current->message)[i]!=rmessage)
                        updatedmessage.push_back((current->message)[i]);
                        
                }                
                current->message = updatedmessage;
                //cout << endl;
                //cout << "new current message: ";         
                //for (size_t i = 0; i < (current->message).size(); i++)
                //{
                //    cout << (current->message)[i]<< " ";
                //}
                //cout << endl;
                found = true;
            }
            else
                current = current->link; //make current point tothe next node
        }
    }
    void removecancellationmessageitem(const string rperson, const string rsubject, const string rmessage)
    {
        //even if different person
        //but updated subject must match, remove message that match
        noticeType *current; //pointer to traverse the list
        bool found = false;
        current = first; //set current to point to the first node in the list
        while (current != NULL && !found)
        {
            bool messageexists = find((current->message).begin(), (current->message).end(), rmessage) != (current->message).end();
            if ( current->subject == rsubject && messageexists) //searchItem is found even if different person
            {
                //cout << endl;
                //cout << "initial current message: ";
                vector<string> updatedmessage;
                for (size_t i = 0; i < (current->message).size(); i++)
                {
                    //cout << (current->message)[i]<< " ";
                    if ((current->message)[i]!=rmessage)
                        updatedmessage.push_back((current->message)[i]);
                        
                }                
                current->message = updatedmessage;
                //cout << endl;
                //cout << "new current message: ";         
                //for (size_t i = 0; i < (current->message).size(); i++)
                //{
                //    cout << (current->message)[i]<< " ";
                //}
                //cout << endl;
                found = true;
            }
            else
                current = current->link; //make current point tothe next node
        }
    }
    void removeItemsemptymessages()
    {
        noticeType *current; //pointer to traverse the list
        noticeType *trailCurrent;// pointer just before current
        noticeType *tempcurrent;
        if (first == NULL) //Case 1; the list is empty.
        {
            //cout << "Cannot delete from an empty list." << endl;
        }
        else if (count == 1) //if list has onlu one Item
        {
            if ((first->message).size() == 0) //Case 2 first node is empthy
            {
                current = first;
                first = NULL;
                last = NULL;
                count--;
                delete current;
            }
        }
        else 
        {
            current = first;
            while (current != last)
            {
                if ((current->message).size()==0) // if empty message delete
                {
                    trailCurrent->link= current-> link;
                    tempcurrent = current;
                    current = current ->link;
                    delete tempcurrent;
                    count--;
                }
                else // if not empty go on
                {
                    trailCurrent = current;
                    current = current ->link;    
                }
            }
            if (current == last)
            {
                if ((current->message).size()==0) // if empty message delete
                {
                    last = trailCurrent;
                    trailCurrent->link = NULL;
                    delete current;
                    count--;
                }
            }
        }
    } 
    void addNewItemtoback(const string nperson, const string nsubject, const string nmessage)
    {
        // insert band new item at the end of list
        noticeType *newNode;
        newNode = new noticeType; //create the new node
        newNode->person = nperson; //store the new item in the node
        newNode->subject = nsubject; //store the new item in the node
        (newNode->message).push_back(nmessage);
        newNode->link = NULL; //set the link field of newNode to NULL
        if (first == NULL) //if the list is empty, newNode is both the first and last node
        {
            first = newNode;
            last = newNode;
            count++; //increment count
        }
        else //the list is not empty, insert newNode after last
        {
            last->link = newNode; //insert newNode after last
            last = newNode; //make last point to the actual last node in the list
            count++; //increment count
        }
    }
    void appendtoexistingItem(const string nperson, const string nsubject, const string nmessage)
    {
        // append  to existing item

        // search possition to apend at
        noticeType *current; //pointer to traverse the list
        bool found=false;
        current = first; //set current to point to the first node in the list
        while (current != NULL && !found)
        {
            string tempPerson = current->person;
            string tempSubject = current->subject;
            if ( tempPerson == nperson && tempSubject == nsubject) //searchItem is found
            {
                //append here
                found = true;
                (current -> message).push_back(nmessage);
            }
            else
                current = current->link; //make current point tothe next node
        }
        
    }
    bool searchDuplicateExist(const string sperson, const string ssubject, const string smessage)
    {
        //search if list contains a node with same person, subject and body 
        //(N/B) handle where the noticetosearch.message is one of the members of messagelist comma delimited string
        noticeType *current; //pointer to traverse the list
        bool found = false;
        current = first; //set current to point to the first node in the list
        while (current != NULL && !found)
        {
            bool messageexists = find((current->message).begin(), (current->message).end(), smessage) != (current->message).end();
            if ( current->person == sperson && current->subject == ssubject && messageexists) //searchItem is found
                found = true;
            else
                current = current->link; //make current point tothe next node
        }
        return found;
    }
    bool searchSubjectMessageExists(const string sperson, const string ssubject, const string smessage)
    {
        //search if list contains same body and subject
        noticeType *current; //pointer to traverse the list
        bool found = false;
        current = first; //set current to point to the first node in the list
        while (current != NULL && !found)
        { 
            bool messageexists = find((current->message).begin(), (current->message).end(), smessage) != (current->message).end();
            if (current->subject == ssubject && messageexists) //searchItem is found
                found = true;
            else
                current = current->link; //make current point tothe next node
        }
        return found;
    }
    bool searchPersonSubjectExists(const string sperson, const string ssubject, const string smessage)
    {
        //search if list contains node with similar person & subject
        noticeType *current; //pointer to traverse the list
        bool found = false;
        current = first; //set current to point to the first node in the list
        while (current != NULL && !found)
        {
            string tempPerson = current->person;
            string tempSubject = current->subject;
            if ( tempPerson == sperson && tempSubject == ssubject) //searchItem is found
                found = true;
            else
                current = current->link; //make current point tothe next node
        }
        return found;
    }

};



int getnumberoffiles( string inputfile)
{
    string input_file_prefix = inputfile.substr(0,inputfile.find_first_of('.')+1);
    int input_file_number = stoi( inputfile.substr(inputfile.find_first_of('.')+1,1));
    bool more_files_to_read = true;
    int numberoffiles = 0;
    while (more_files_to_read)
    {
        ifstream file(inputfile);
        if (file) 
        {
            numberoffiles++;
            input_file_number++;
            inputfile=input_file_prefix+to_string(input_file_number)+".txt";
        }
        else
        {
            more_files_to_read=false;
        }
        file.close();
    }
    return numberoffiles;
}

int main(int argc, char* argv[])
{
    //get the number of files to be opened
    string file_to_read = static_cast <string> (argv[1]);
    string inputfile = file_to_read.substr(6,file_to_read.length()-6);
    if (inputfile.substr(0,2)=="./")
        inputfile.erase(0,2);
    else if (inputfile.substr(0,1)=="/")
        inputfile.erase(0,1);
    string fileprefix = inputfile.substr(0,inputfile.find_first_of('.')+1);
    int filenumber = stoi(inputfile.substr(inputfile.find_first_of('.')+1,1));
    int numberoffiles = getnumberoffiles(inputfile);
    //cout <<  "filenumber: " << filenumber<< endl ;
    //cout <<  "number of files: " << numberoffiles<< endl ;
    //create an array for each for each file result
    //vector<string>perfileop;
    vector<linkedlisttype>perfileop;
    
    //for each file
    for(int i=filenumber;i<=numberoffiles; i++)
    {
        //create a linked list for the file
        linkedlisttype listA;

        //open and read the file
        string filetoopen =  fileprefix+to_string(i)+".txt";
        //cout << "filetoopen: " << filetoopen<<endl;
        ifstream file(filetoopen);
        //NB no need to check if file can be opened again, we already checked in function getnumberoffiles

        //for eachline
        string line;
        while(getline(file, line)) 
        {
            //cout << line <<endl;
            //trim white space from the beginning of the string
            line.erase(line.begin(), find_if(line.begin(), line.end(), not1(ptr_fun<int, int>(isspace)))); 
    
            //ignore if line is empty or starts with # ie is a comment
            if (line == "" || line.substr(0,1)=="#")
            {
                //ignore line
            }
            else
            {
                //continue: extract content of notice on eachline             
                string person = line.substr(0,line.find_first_of('\t'));
                line.erase(0,line.find_first_of('\t')+1);
                string subject = line.substr(0,line.find_first_of('\t'));
                line.erase(0,line.find_first_of('\t')+1);
                string message = line;
                //cout << "person=" << person << "; subject=" << subject << "; message="<< message << endl;

                //process item to see if it should be added to linkedlist,or to a previous similar notice in the linkedlist, 
                //or should be ignored or if similar older message should be removed, and or replaced with this and do likewise.
                //cout << "calling additem";
                listA.additem_workflow(person, subject, message);
            }
        }

        //listA.print(); save linkedlist to string array
        //perfileop.push_back( listA.tostring());
        perfileop.push_back( listA);
        file.close();   
        //end of 1 inputfile     
    }


    //create global linkedlist
    linkedlisttype globallist;
    //get the longest list
    int lenlongest=0;
    for (size_t i = 0; i < numberoffiles ; i++) //for each file
    {
        //cout << perfileop[i].tostring()<<endl;
        if (perfileop[i].getcount()>lenlongest)
            lenlongest = perfileop[i].getcount();
    }

    //cout << "lenlongest = "<< lenlongest<< "aaa"<< endl;
        
    //cout <<"before noticeType *current[numberoffiles]"<<endl;
    noticeType *current[numberoffiles];
    //assign currentpointer for eachfile to head
    //cout <<"after creating current pointer array"<< endl;
    
    for (size_t k = 0; k < numberoffiles; k++)
    {
        current[k]=perfileop[k].gethead();
    }
    //cout << "end for loop" <<endl;

   
    //for each line extract info per file
    for (size_t i = 0; i < lenlongest; i++) // for each line of longest file
    {
        //cout << "i = "<<i<<endl;
        for (size_t j = 0; j < numberoffiles ; j++) //for each file
        {
            //cout << "       j = "<<j<< endl;
            //take the nextline i of each file (perfileop[j])
            if (current[j] != NULL)
            {
                string onelineofonefileperson = current[j]->person;
                string onelineofonefilesubject = current[j]->subject;
                vector<string> onelineofonefilemessage = current[j]->message;

                cout << "   "<< onelineofonefileperson << " " << onelineofonefilesubject << endl;
                
                //cout << "end of j" << endl ;

                current[j] = current[j]->link;
            }
            //cout << "inside fake inner loop" << endl;
            
        }
        //cout ": before increasing current"
        //cout <<endl;    
        //cout << "inside fake inner for loop" << endl ;

    }
    //cout << "ended double for loop" << endl;
/*
    //from the each pointers in #2 above 
    //get notification one from each pointer at a time using current = ponter; current = current ->pointer
    //add items to global list using additem_special
    //print out global list
    */

    //destroy the linkedlists?
    for (size_t i = 0; i < numberoffiles ; i++) //for each file
    {
        perfileop[i].destroyList();
    }

}
