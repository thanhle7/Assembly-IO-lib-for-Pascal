program tuc;
Uses    io;

const
    { ======= Menu Infos }
        n = 5;          { Pad number }
        m = 5;          { Bar Number }
        padprompt: array[1..n] of string = (' Languages ', ' Computer ',
                                          ' Math ', ' Games ', ' System ');
        padwidth : array[1..n] of byte   = (13, 13, 13, 11, 13);
        padpos   : array[1..n] of byte   = (0 , 12, 23, 30, 38);
        padlength: array[1..n] of byte   = (5 ,  5,  2, 5, 2);
        popprompt: array[1..n, 1..m] of string =
          (('1.Pretest  ', '2.Answer   ', '3.Result   ','Ä', '4.Choosing '),
           ('1.MS-DOS   ', '2.Assembly ', '3.Pascal   ','4.C/C++    ', '5.Foxpro   '),
           ('1.Heristic ', '2.Lines    ','','',''),
           ('1.Words  ', '2.Puzzle ', '3.Inter  ','Ä','4.News   '),
           ('1.Help     ', '2.Manager  ','Ä','3.Add Data ','4.Extract  '));
     { ======= End of Menu Infos }
{----------------------------------}

var
  pad, pop: byte;

Procedure  GetMenu(var pad: byte; var pop: byte);

Var
  o_color, o_row, o_col, o_getcolor: byte;
  padno, popno, i: byte;

Begin
  o_color := color; o_row := row; o_col := col; o_getcolor := get_color;
  Backup_screen; cursor_off; box_base := 1; get_color := 113;

  Gotoxy(0, 0); color := 63; fill_char(' ',40);

  padno := 1; popno := 0;
  Repeat
     prompt_point := padno;
     Exit_key1 := Down_key; Exit_key2 := Down_key;

     If (Popno > 0) Then Exit_key := 0
     Else Exit_key := 1;

     row := 0;
     for i := 1 to n do
         begin
             col := padpos[i];
             prompt(padprompt[i]);
         end;
     read_prompt;
     If  (Exit_key = Esc_key) Then Break;

     Backup_screen;
     padno := prompt_point; popno := 1; Exit_key := 1;

     color := 48;
     box(1,padpos[padno],2+padlength[padno],padpos[padno]+padwidth[padno],single_frame);

     row := 1; Col := padpos[padno] + 1;
     prompt_point := popno;
     Exit_key1 := Left_key; Exit_key2 := Right_key;
     For i := 1 To Padlength[padno] Do
         Begin
            Row := Row + 1;
            if (popprompt[padno, i][1] = 'Ä') Then
               Begin
                  color := 48;
                  box(row, col-1, row, col+padwidth[padno]-1,Single_bar);
               End
            else
               Begin
                  color := 63;
                  prompt(popprompt[padno, i]);
               End;
         End;
     read_prompt;

     Case Exit_key of
          Left_key:
               if padno > 1 then
                  padno := padno - 1
               else
                  padno := n;
          Right_key:
               if padno < n then
                  padno := padno + 1
               else
                  padno := 1;
          Esc_key:
               Popno := 0;
          Else
               popno := prompt_point;
     End;
     Restore_screen;
  Until (Exit_key = Enter_key) or (Exit_key = 0);
  color := o_color; row := o_row; col := o_col; get_color := o_getcolor;
  Restore_screen; cursor_on;

  pad := padno; pop := popno;
End;


Begin
  gotoxy(0,0);
  color := 11; fill_char('°',80*24);
  color := 63; fill_char(' ',80);

  Color := 32;
  Zoom(2,15, 20, 67, Single_frame);
  Gotoxy(21, 9); Write('Chao. cac ban~');
  pict(2,1);
  Gotoxy(21,11); Write(10:3);

  Repeat
      Getmenu(pad, pop);
      If (padlength[5] = 2) Then
         begin
            padlength[5] := 5;
            popprompt[5,2] := '2.User     ';
         end
      Else
         begin
            padlength[5] := 2;
            popprompt[5,2] := '2.Manager  ';
         end;
  Until (Exit_key = Esc_key);

  color := 7; clrscr;
  Gotoxy(Row, Col);
  pict(2,1);
  if (pop >0 ) Then Write('Ban da chon ', pad:2,':', pop:2)
  Else  Write('Chao cac ban ', pad:2,':', pop:3);
End.
