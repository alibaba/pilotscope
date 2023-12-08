/*-------------------------------------------------------------------------
 *
 * hashtable.c
 *	  Routines to provide a base hash table ability for pilotscope
 *
 * Note that we use the linkedlist to deal with hash conficts.
 * 
 * We use hash_bytes in the source code of pg as our hash function for convinience.
 *  
 * Copyright (c) 2023, Damo Academy of Alibaba Group
 * -------------------------------------------------------------------------
 */

/** temporarily remove hashtable **/
/* Temporarily don't use hash table. Getting cards by index instead by key.

#include "pilotscope/hashtable.h"

int table_size = 1;
Hashtable* table;

static Entry* create_entry(const char* key, const char* value);

// get hash
unsigned int hash(const char* key) 
{
    unsigned int hash_val=hash_bytes((const unsigned char*)key,strlen(key));
    return hash_val % table_size;
}

// create entry
Entry* create_entry(const char* key, const char* value) 
{
    Entry* entry = (Entry*)palloc(sizeof(Entry));
    entry->key   = (char*)palloc(strlen(key) + 1);
    entry->value = (char*)palloc(strlen(value) + 1);
    entry->next  = NULL;
    strcpy(entry->key, key);
    strcpy(entry->value, value);
    return entry;
}

// create hash table
Hashtable* create_hashtable() 
{
    Hashtable* table = (Hashtable*)palloc(sizeof(Hashtable));
    table->entries   = (Entry**)palloc0(table_size*sizeof(Entry*));
    return table;
}

// put item into hashtable
void put(Hashtable* table, const char* key, const char* value) 
{
    unsigned int index = hash(key);
    if (table->entries[index] == NULL) 
    {
        table->entries[index] = create_entry(key, value);
    } 
    else 
    {
        Entry* current = table->entries[index];
        while (current != NULL) 
        {
            if (strcmp(current->key, key) == 0) 
            {
                strcpy(current->value, value);
                return;
            }
            current = current->next;
        }
        Entry* entry = create_entry(key, value);
        entry->next  = table->entries[index];
        table->entries[index] = entry;
    }
}

// get value from hashtable according to the key
char* get(Hashtable* table, const char* key) 
{
    unsigned int index = hash(key);
    Entry* current = table->entries[index];
    while (current != NULL) 
    {
        if (strcmp(current->key, key) == 0) 
        {
            return current->value;
        }
        current = current->next;
    }
    return NULL;
}

*/