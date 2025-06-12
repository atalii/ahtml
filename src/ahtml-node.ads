--  This Source Code Form is subject to the terms of the Mozilla Public
--  License, v. 2.0. If a copy of the MPL was not distributed with this
--  file, You can obtain one at https://mozilla.org/MPL/2.0/.

with Ada.Containers.Vectors;

with AHTML.Strings;

package AHTML.Node is

   type Node_Handle is private;
   type Doc is tagged private;

   type Attr is record
      Key : AHTML.Strings.Name;
      Val : AHTML.Strings.Cooked;
   end record;

   Null_Doc : constant Doc;
   --  Null_Doc is an empty doc.

   HTML_Doc : constant Doc;
   --  HTML_Doc is identical to Null_Doc except that the DOCTYPE
   --  is set to html.

   function Mk_Element (D : in out Doc; Name : String) return Node_Handle;
   function Mk_Element
      (D : in out Doc; Name : AHTML.Strings.Name)
      return Node_Handle;

   function Mk_Text (D : in out Doc; Content : String) return Node_Handle;
   function Mk_Text
      (D : in out Doc; Content : AHTML.Strings.Cooked)
      return Node_Handle;

   function Mk_Attr
      (Key : AHTML.Strings.Name; Val : AHTML.Strings.Cooked)
      return Attr;

   procedure With_Doctype (D : in out Doc; T : AHTML.Strings.Cooked);
   procedure With_Child (D : in out Doc; N, C : Node_Handle);
   procedure With_Attribute (D : in out Doc; N : Node_Handle; A : Attr);

   --  Stringify a specific node.
   function To_String (D : Doc; N : Node_Handle)
      return AHTML.Strings.Raw;

   --  Stringify from the root of the document (assumed to be the first
   --  inserted node.)
   function To_String (D : Doc) return AHTML.Strings.Raw;

private

   type Maybe_Doctype (Present : Boolean := False) is record
      case Present is
         when True => Doctype : AHTML.Strings.Cooked;
         when False => null;
      end case;
   end record;

   type Node_Handle is new Natural;

   package Attrs_Vec is new Ada.Containers.Vectors
      (Index_Type => Natural, Element_Type => Attr);

   package Index_Vec is new Ada.Containers.Vectors
      (Index_Type => Node_Handle, Element_Type => Node_Handle);

   type Node_Kind is (Text, Element);

   type Node_Inner (K : Node_Kind := Text) is record
      case K is
         when Text => Content : AHTML.Strings.Cooked;

         when Element =>
            Name : AHTML.Strings.Name;
            Attrs : Attrs_Vec.Vector;
            Children : Index_Vec.Vector;
      end case;
   end record;

   type Node is tagged record
      Inner : Node_Inner;
   end record;

   package Node_Vec is new Ada.Containers.Vectors
      (Index_Type => Node_Handle, Element_Type => Node);

   type Doc is tagged record
      Doctype : Maybe_Doctype;
      Inner : Node_Vec.Vector;
   end record;

   function Mk_Element (Name : AHTML.Strings.Name) return Node_Inner;

   Null_Doc : constant Doc :=
     (Inner => Node_Vec.Empty_Vector, Doctype => (Present => False));

   Html_Doc : constant Doc :=
     (Inner => Node_Vec.Empty_Vector, Doctype =>
        (Present => True, Doctype => AHTML.Strings.Cook ("html")));

end AHTML.Node;
