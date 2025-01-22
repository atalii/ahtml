--  This Source Code Form is subject to the terms of the Mozilla Public
--  License, v. 2.0. If a copy of the MPL was not distributed with this
--  file, You can obtain one at https://mozilla.org/MPL/2.0/.

package body AHTML.Node is

   use Ada.Containers;

   use AHTML.Strings;
   use Attrs_Vec;
   use Node_Vec;

   function Null_Doc return Doc is
      ((Inner => Node_Vec.Empty_Vector,
      Doctype => (Present => False)));

   function HTML_Doc return Doc
   is
      D : Doc := Null_Doc;
   begin
      D.With_Doctype (Cook ("html"));
      return D;
   end HTML_Doc;

   function Mk_Element (D : in out Doc; Name : String) return Node_Handle is
      (D.Mk_Element (AHTML.Strings.Denote (Name)));

   function Mk_Element (D : in out Doc; Name : AHTML.Strings.Name)
      return Node_Handle
   is
      N : constant Node := (Inner => Mk_Element (Name));
   begin
      D.Inner.Append (N);
      return D.Inner.Last_Index;
   end Mk_Element;

   function Mk_Text (D : in out Doc; Content : String) return Node_Handle is
      (D.Mk_Text (AHTML.Strings.Cook (Content)));

   function Mk_Text (D : in out Doc; Content : AHTML.Strings.Cooked)
      return Node_Handle
   is
      N : constant Node := (Inner => (K => Text, Content => Content));
   begin
      D.Inner.Append (N);
      return D.Inner.Last_Index;
   end Mk_Text;

   function Mk_Attr
      (Key : AHTML.Strings.Name; Val : AHTML.Strings.Cooked)
      return Attr is (Key => Key, Val => Val);

   procedure With_Child (D : in out Doc; N, C : Node_Handle)
   is
      procedure Update (N : in out Node) is
      begin
         N.Inner.Children.Append (C);
      end Update;
   begin
      D.Inner.Update_Element (N, Update'Access);
   end With_Child;

   procedure With_Attribute (D : in out Doc; N : Node_Handle; A : Attr)
   is
      procedure Update (N : in out Node) is
      begin
         N.Inner.Attrs.Append (A);
      end Update;
   begin
      D.Inner.Update_Element (N, Update'Access);
   end With_Attribute;

   procedure With_Doctype (D : in out Doc; T : AHTML.Strings.Cooked)
   is begin
      D.Doctype := (Present => True, Doctype => T);
   end With_Doctype;

   function To_String (D : Doc; N : Node_Handle) return AHTML.Strings.Raw
   is

      use SU;

      Tmp : AHTML.Strings.Raw;

      procedure Stringify_Element (Target : Node_Inner);
      procedure Stringify_Node (Target : Node);

      procedure Stringify_Element (Target : Node_Inner)
      is
         Have_Children : constant Boolean :=
            Target.Children.Length /= 0;
      begin
         Tmp := @ & "<" & Target.Name.Unwrap;

         for Attr of Target.Attrs loop
            Tmp := @ & " " &
               Attr.Key.Unwrap & "=" & '"' &
               Attr.Val.Unwrap & '"';
         end loop;

         if Have_Children then
            Tmp := @ & ">";
         end if;

         for Child of Target.Children loop
            Stringify_Node (D.Inner (Child));
         end loop;

         if Have_Children then
            Tmp := @ & ("</" & Target.Name.Unwrap & ">");
         else
            Tmp := @ & "/>";
         end if;
      end Stringify_Element;

      procedure Stringify_Node (Target : Node) is
      begin
         case Target.Inner.K is
            when Element => Stringify_Element (Target.Inner);
            when Text =>
               Tmp := @ & Target.Inner.Content.Unwrap;
         end case;
      end Stringify_Node;

   begin
      if D.Doctype.Present then
         Tmp := @ & "<!DOCTYPE " & D.Doctype.Doctype.Unwrap & ">";
      end if;

      Stringify_Node (D.Inner (N));

      return Tmp;
   end To_String;

   function To_String (D : Doc) return AHTML.Strings.Raw
      is (D.To_String (Node_Handle (0)));

   function Mk_Element (Name : AHTML.Strings.Name) return Node_Inner
   is ((K => Element,
       Name => Name,
       Attrs => Attrs_Vec.Empty_Vector,
       Children => Index_Vec.Empty_Vector));

end AHTML.Node;
