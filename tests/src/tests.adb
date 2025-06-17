--  This Source Code Form is subject to the terms of the Mozilla Public
--  License, v. 2.0. If a copy of the MPL was not distributed with this
--  file, You can obtain one at https://mozilla.org/MPL/2.0/.

with AHTML.Node; use AHTML.Node;
with AHTML.Strings; use AHTML.Strings;
with VSS.Strings; use VSS.Strings;
with VSS.Text_Streams; use VSS.Text_Streams;
with VSS.Text_Streams.Standards; use VSS.Text_Streams.Standards;

procedure Tests is

   Test_Failure : exception;

   procedure Assert_Becomes
      (Doc : AHTML.Node.Doc; Expected : Virtual_String)
   is
      Actual : constant AHTML.Strings.Raw := Doc.To_String;
      Success : Boolean := True;

      SE : Output_Text_Stream'Class := Standard_Error;
   begin
      if Actual /= Expected then
         Put_Line (SE, "Expected: " & Expected, Success);
         Put_Line (SE, "Actual:   " & Actual, Success);
         raise Test_Failure;
      end if;
   end Assert_Becomes;

   procedure Test_HTML_Basic_Gen
   is
      Doc : AHTML.Node.Doc := AHTML.Node.HTML_Doc;
      Root : constant AHTML.Node.Node_Handle := Doc.Mk_Element ("html");
      Body_Node : constant AHTML.Node.Node_Handle := Doc.Mk_Element ("body");
      Text_Node : constant AHTML.Node.Node_Handle := Doc.Mk_Text ("test");

      Attr : constant AHTML.Node.Attr :=
         AHTML.Node.Mk_Attr (Denote ("a"), Cook ("b"));

   begin

      Assert_Becomes (Doc, "<!DOCTYPE html><html/>");

      Doc.With_Child (Root, Body_Node);
      Assert_Becomes (Doc, "<!DOCTYPE html><html><body/></html>");

      Doc.With_Attribute (Body_Node, Attr);
      Assert_Becomes (Doc, "<!DOCTYPE html><html><body a=""b""/></html>");

      Doc.With_Child (Body_Node, Text_Node);
      Assert_Becomes (Doc,
        "<!DOCTYPE html><html><body a=""b"">test</body></html>");

   end Test_HTML_Basic_Gen;

   procedure Test_XML_Basic_Gen
   is
      Doc : AHTML.Node.Doc := AHTML.Node.XML_Doc;
      Item : constant AHTML.Node.Node_Handle := Doc.Mk_Element ("thing");
      Attr : constant AHTML.Node.Attr := AHTML.Node.Mk_Attr
        (Denote ("key"), Cook ("val"));
   begin
      Assert_Becomes (Doc, "<?xml version='1.0' encoding='utf-8' ?><thing/>");

      Doc.With_Attribute (Item, Attr);
      Assert_Becomes (Doc,
        "<?xml version='1.0' encoding='utf-8' ?><thing key=""val""/>");

   end Test_XML_Basic_Gen;

begin
   Test_HTML_Basic_Gen;
   Test_XML_Basic_Gen;
end Tests;
