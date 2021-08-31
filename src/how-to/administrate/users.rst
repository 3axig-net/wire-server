.. _investigative_tasks:

Investigative tasks (e.g. searching for users as server admin)
---------------------------------------------------------------

This page requires that you have root access to the machines where kubernetes runs on, or have kubernetes permissions allowing you to port-forward arbitrary pods and services.

If you have the `backoffice` pod installed, see also the `backoffice README <https://github.com/wireapp/wire-server/tree/develop/charts/backoffice>`__.

If you don't have `backoffice`, see below for some options:

Manually searching for users in cassandra
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Terminal one:

.. code:: sh

   kubectl port-forward svc/brig 9999:8080

Terminal two: Search for your user by email:

.. code:: sh

   EMAIL=user@example.com
   curl -v -G localhost:9999/i/users --data-urlencode email=$EMAIL; echo
   # or, for nicer formatting
   curl -v -G localhost:9999/i/users --data-urlencode email=$EMAIL | json_pp

You can also search by ``handle`` (unique username) or by phone:

.. code:: sh

   HANDLE=user123
   curl -v -G localhost:9999/i/users --data-urlencode handles=$HANDLE; echo

   PHONE=+490000000000000 # phone numbers must have the +country prefix and no spaces
   curl -v -G localhost:9999/i/users --data-urlencode phone=$PHONE; echo


Which should give you output like:

.. code:: json

   [
      {
         "managed_by" : "wire",
         "assets" : [
            {
               "key" : "3-2-a749af8d-a17b-4445-b360-46c93fc41bc6",
               "size" : "preview",
               "type" : "image"
            },
            {
               "size" : "complete",
               "type" : "image",
               "key" : "3-2-6cac6b57-9972-4aba-acbb-f078bc538b54"
            }
         ],
         "picture" : [],
         "accent_id" : 0,
         "status" : "active",
         "name" : "somename",
         "email" : "user@example.com",
         "id" : "9122e5de-b4fb-40fa-99ad-1b5d7d07bae5",
         "locale" : "en",
         "handle" : "user123"
      }
   ]

The interesting part is the ``id`` (in the example case ``9122e5de-b4fb-40fa-99ad-1b5d7d07bae5``):

.. _user-deletion:

Deleting a user which is not a team user
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The following will completely delete a user, its conversations, assets, etc. The only thing remaining will be an entry in cassandra indicating that this user existed in the past (only the UUID remains, all other attributes like name etc are purged)

You can now delete that user by double-checking that the user you wish to delete is really the correct user:

.. code:: sh

   # replace the id with the id of the user you want to delete
   curl -v localhost:9999/i/users/9122e5de-b4fb-40fa-99ad-1b5d7d07bae5 -XDELETE

Afterwards, the previous command (to search for a user in cassandra) should return an empty list (``[]``).

When done, on terminal 1, ctrl+c to cancel the port-forwarding.

Manual search on elasticsearch (via brig, recommended)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

This should only be necessary in the case of some (suspected) data inconsistency between cassandra and elasticsearch.

Terminal one:

.. code:: sh

   kubectl port-forward svc/brig 9999:8080

Terminal two: Search for your user by name or handle or a prefix of that handle or name:

.. code:: sh

   NAMEORPREFIX=test7
   UUID=$(cat /proc/sys/kernel/random/uuid)
   curl -H "Z-User:$UUID" "http://localhost:9999/search/contacts?q=$NAMEORPREFIX"; echo
   # or, for pretty output:
   curl -H "Z-User:$UUID" "http://localhost:9999/search/contacts?q=$NAMEORPREFIX" | json_pp

If no match is found, expect a query like this:

.. code:: json

   {"took":91,"found":0,"documents":[],"returned":0}

If matches are found, the result should look like this:

.. code:: json

   {
      "found" : 2,
      "documents" : [
         {
            "id" : "dbdbf370-48b3-4e1e-b377-76d7d4cbb4f2",
            "name" : "Test",
            "handle" : "test7",
            "accent_id" : 7
         },
         {
            "name" : "Test",
            "accent_id" : 0,
            "handle" : "test7476",
            "id" : "a93240b0-ba89-441e-b8ee-ff4403808f93"
         }
      ],
      "returned" : 2,
      "took" : 4
   }

How to manually search for a user on elasticsearh directly (not recommended)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

First, ssh to an elasticsearch instance.

.. code:: sh

  ssh <ip of elastisearch instance> 

Then run the following:

.. code:: sh

   PREFIX=...
   curl -s "http://localhost:9200/directory/_search?q=$PREFIX" | json_pp

The `id` (UUID) returned can be used when deleting (see below).

How to manually delete a user from elasticsearch only
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. warning::

   This is NOT RECOMMENDED. Be sure you know what you're doing. This only deletes the user from elasticsearch, but not from cassandra. Any change of e.g. the username or displayname of that user means this user will re-appear in the elasticsearch database. Instead, either fully delete a user: :ref:`user-deletion` or make use of the internal GET/PUT ``/i/searchable`` endpoint on brig to make this user prefix-unsearchable.

If, despite the warning, you wish to continue?

First, ssh to an elasticsearch instance:

.. code:: sh

  ssh <ip of elastisearch instance> 

Next, check that the user exists:

.. code:: sh

   UUID=...
   curl -s "http://localhost:9200/directory/user/$UUID" | json_pp

That should return a ``"found": true``, like this:

.. code:: json

   {
      "_type" : "user",
      "_version" : 1575998428262000,
      "_id" : "b3e9e445-fb02-47f3-bac0-63f5f680d258",
      "found" : true,
      "_index" : "directory",
      "_source" : {
         "normalized" : "Mr Test",
         "handle" : "test12345",
         "id" : "b3e9e445-fb02-47f3-bac0-63f5f680d258",
         "name" : "Mr Test",
         "accent_id" : 1
      }
   }


Then delete it:

.. code:: sh

   UUID=...
   curl -s -XDELETE "http://localhost:9200/directory/user/$UUID" | json_pp
