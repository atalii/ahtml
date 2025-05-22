--  This Source Code Form is subject to the terms of the Mozilla Public
--  License, v. 2.0. If a copy of the MPL was not distributed with this
--  file, You can obtain one at https://mozilla.org/MPL/2.0/.

with AHTML.Node; use AHTML.Node;
with AHTML.Strings; use AHTML.Strings;
with VSS.Strings; use VSS.Strings;
with VSS.Strings.Conversions;

procedure Tests is

   Test_Failure : exception;

   procedure Assert_Becomes
      (Doc : AHTML.Node.Doc; Expected : String)
   is
      Actual : constant AHTML.Strings.Raw := Doc.To_String;
   begin
      if Actual /= VSS.Strings.Conversions.To_Virtual_String (Expected) then
         raise Test_Failure;
      end if;
   end Assert_Becomes;

   procedure Test_Basic_Gen
   is
      Doc : AHTML.Node.Doc := AHTML.Node.Null_Doc;
      Root : constant AHTML.Node.Node_Handle := Doc.Mk_Element ("html");
      Body_Node : constant AHTML.Node.Node_Handle := Doc.Mk_Element ("body");
      Text_Node : constant AHTML.Node.Node_Handle := Doc.Mk_Text ("test");

      Attr : constant AHTML.Node.Attr :=
         AHTML.Node.Mk_Attr (Denote ("a"), Cook ("b"));

   begin
      Assert_Becomes (Doc, "<html/>");

      Doc.With_Child (Root, Body_Node);
      Assert_Becomes (Doc, "<html><body/></html>");

      Doc.With_Attribute (Body_Node, Attr);
      Assert_Becomes (Doc, "<html><body a=""b""/></html>");

      Doc.With_Child (Body_Node, Text_Node);
      Assert_Becomes (Doc, "<html><body a=""b"">test</body></html>");

      Doc.With_Doctype (Cook ("html"));
      Assert_Becomes
         (Doc,
          "<!DOCTYPE html><html><body a=""b"">test</body></html>");
   end Test_Basic_Gen;

begin
   Test_Basic_Gen;
end Tests;
