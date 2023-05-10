with Ada.Text_IO, GNAT.Semaphores;
use Ada.Text_IO, GNAT.Semaphores;

with Ada.Containers.Indefinite_Doubly_Linked_Lists;
use Ada.Containers;

procedure Main is
   package String_Lists is new Indefinite_Doubly_Linked_Lists (String);
   use String_Lists;

   procedure FC(size, amountElems: Integer) is
      storage: List;

      storage_access: Counting_Semaphore(1, Default_Ceiling);
      storage_not_full : Counting_Semaphore(size, Default_Ceiling);
      storage_not_empty : Counting_Semaphore(0, Default_Ceiling);

      task type fabricator is
         entry start(id1: Integer);
      end fabricator;

      task type consumer is
         entry start(id1: Integer);
      end consumer;

      task body fabricator is
         id: Integer := 0;
         begin
         accept start(id1: Integer) do
            id := id1;
         end start;
         for i in 1..amountElems loop
            storage_not_full.Seize;
            storage_access.Seize;


            storage_not_empty.Release;
            storage_access.Release;
            delay 1.0;
         end loop;
      end fabricator;

      task body consumer is
         id: Integer := 0;
         begin
         accept start(id1: Integer) do
            id := id1;
         end start;
         for i in 1..amountElems loop
            storage_not_empty.Seize;
            storage_access.Seize;
            storage.Delete_First;

            storage_not_full.Release;
            storage_access.Release;
            delay 1.0;
         end loop;
      end consumer;

      fabricators: array(1..5) of fabricator;
      consumers: array(1..5) of consumer;

   begin
      for i in 1..5 loop
         fabricators(i).start(id1 => i);
         consumers(i).start(id1 => i);
      end loop;
   end FC;
begin
   FC(3, 5);
end Main;
