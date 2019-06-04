unit EMPIO;
{$s-}
{$b-}
{$v-}
{$i-}
{$r-}
{$f+}
interface
  type
    Date    = record
                 Year : array [1..4] of char;
                 Month: array [1..2] of char;
                 Day  : array [1..2] of char;
              end;

    str_box = string[9];
    str_3   = string[3];
    str_9   = string[9];
    get_ele = record
                 ele_type  : word;
                 ele_point : pointer;
                 size      : byte;
                 dec       : byte;
                 col       : byte;
                 row       : byte;
                 Check_prog: pointer;
                 Sub_proc  : pointer;
              end;

    Prompt_ele = record
                 ele_point : pointer;
                 col       : byte;
                 row       : byte;
               end;

    TextBuf = array[0..127] of char;
    TextRec = record
               Handle: Word;
               Mode: Word;
               BufSize: Word;
               Private: Word;
               BufPos: Word;
               BufEnd: Word;
               BufPtr: ^TextBuf;
               OpenFunc: Pointer;
               InOutFunc: Pointer;
               FlushFunc: Pointer;
               CloseFunc: Pointer;
               UserData: array[1..16] of byte;
               Name: array[0..79] of char;
               Buffer: TextBuf;
              end;

{------------- Constant declare ----------------------------------------------}
  const

{------ Color constance }
      Black         = 0;
      Blue          = 1;
      Green         = 2;
      Cyan          = 3;
      Red           = 4;
      Magenta       = 5;
      Brown         = 6;
      LightGray     = 7;
      DarkGray      = 8;
      LightBlue     = 9;
      LightGreen    = 10;
      LightCyan     = 11;
      LightRed      = 12;
      LightMagenta  = 13;
      Yellow        = 14;
      White         = 15;
      Blink         = 128;

{-------- Used for Inkey : ( include ASCII code and keyboard scan code )}
      SPACE_BAR       =    $3920;
      Enter_key       =    $1C0D;
      ESC_key         =    $011B;
      Tab_key         =    $0F09;
      ShiftTab_key    =    $0F00;
      Up_key          =    $4800;
      Down_key        =    $5000;
      Left_key        =    $4B00;       CtrlLeft_key        =    $7300;
      Right_key       =    $4D00;       CtrlRight_key       =    $7400;
      Home_key        =    $4700;       CtrlHome_key        =    $7700;
      End_key         =    $4F00;       CtrlEnd_key         =    $7500;
      PgUp_key        =    $4900;       CtrlPgUp_key        =    $8400;
      PgDn_key        =    $5100;       CtrlPgDn_key        =    $7600;
      F1_key          =    $3B00;
      F2_key          =    $3C00;
      F3_key          =    $3D00;
      F4_key          =    $3E00;
      F5_key          =    $3F00;
      F6_key          =    $4000;
      F7_key          =    $4100;
      F8_key          =    $4200;
      F9_key          =    $4300;
      F10_key         =    $4400;

{------- Used for Zoom,Box procedure }
      Single_frame    =   'ÚÄ¿³ÙÄÀ³ ';  { string[9] }
      Single_bar      =   'ÃÄ´'      ;  { string[3] }
      Single_pol      =   'Â³Á'      ;  { string[3] }

      Double_frame    =   'ÉÍ»º¼ÍÈº ';  { string[9] }
      Double_bar      =   'ÖÍ¹'      ;  { string[3] }
      Double_pol      =   'Ð³Ò'      ;  { string[3] }

{------- Used for Out_function }
      Rewrite_mode    =   0          ;
      Append_mode     =   1          ;

{------- Used for Date_type }
      American_Type   =   0          ;
      French_Type     =   1          ;
      Empty_Date :date= (Year:'    ' ; Month:'  ' ; Day:'  ');

{------- Prompt & get buffer size }

      Max_get       = 50 ;
      Max_prompt    = 50 ;


{------------- Variable declare ----------------------------------------------}
  var
     Video_seg     : word;
     CRT_port      : word;
     Check_snow    : Boolean;

     color         : byte;
     row           : byte;
     col           : byte;
     Zoom_mode     : byte;
     Box_base      : Byte;

     Exit_key      :  word  ;
     Exit_key1     :  word  ;
     Exit_key2     :  word  ;
     EMP_VNI_KEY   :  boolean;

     get_color     :  byte  ;
     get_count     :  word  ;
     get_point     :  word  ;
     Last_pos      :  word  ;
     get_pos       :  byte  ;
     Get_Mode      :  byte  ;
     get_Confirm   :  Boolean;
     GS_Check      :  Boolean;

     Prompt_point  :  word;
     Prompt_count  :  word;

     Brow_point    :  word;

     Out_Stat      :  word;
     Prow          :  word;
     Pcol          :  word;

     Date_separate : char ;
     Date_type     : byte ;

     Hour          : byte;
     Minute        : byte;
     Second        : byte;
     Mili_Second   : byte;

{---- Music ----------------------------------}

  Procedure Box(x1,y1,x2,y2:word ; a :str_box );
  Procedure Zoom(x1,y1,x2,y2:word ; a :str_box );
  Procedure scroll(x1,y1,x2,y2:word;line_scroll:integer);
  Procedure Set_Attrib(x1,y1,x2,y2:word;color:byte);
  Procedure Fill_char(Char_fill:char;Fill_count:word);
  procedure Clear   ;
  procedure Backup_Screen;
  procedure Restore_Screen;
  Procedure Cursor_on;
  Procedure Cursor_off;
  procedure Delay(Count:word);
  procedure Gettime;
  procedure Sound(Freq:word);
  procedure Sound_on;
  procedure Sound_off;

{ function  GetExcPath: String; }
  procedure GetIntVec(IntNo: Byte; var Vector: Pointer);
  procedure SetIntVec(IntNo: Byte; Vector: Pointer);
  procedure EMP_VNI_Load;
  procedure EMP_VNI_UnLoad;
  procedure RunAddr(Addr: Pointer);
{ procedure Exec(cmd, cml: String);}

{ For compatible with CRT unit ---------------------}
  Procedure Gotoxy(col,row:word);
  Procedure TextColor(color:byte);
  Procedure TextBackground(color:byte);
  procedure ClrScr;
  Procedure NoSound;
{---------------------------------------------------}

  procedure get_str(var ZZZ);

  procedure Readg;
  procedure Disp_get;
  procedure getc(var ZZZ);
  procedure gets(var ZZZ);
  procedure geti(var ZZZ);
  procedure getl(var ZZZ);
  procedure getr(var ZZZ);
  procedure getd(var ZZZ);
  procedure pict(size,dec: word);
  procedure Valid(KKK : pointer);
  procedure SubProc(KKK : pointer);
  function  Inkey      : word;
  function  Inchar     : char;
  function  KeyPressed : boolean;

  procedure WScr     ;
  procedure Write_Str;

  Procedure Prompt(chuoi:string);
  Procedure Read_Prompt;
  Procedure Brow(row,col,ele_size,disp_num,max_num:word;buffer:pointer);

{-Print function------------------------------------}

  Procedure Out_To_File(file_name:string;mode:byte);
  Procedure Out_To_screen                ;
  Procedure Eject                        ;
  Procedure Reset_PRN                    ;

{-Date function-------------------------------------}

  Function Dtoc(var Date_value: date)  :string;
  Function Day(var Date_value: date)   :integer;
  Function Month(var Date_value: date) :integer;
  Function Year(var Date_value: date)  :integer;

{-String function-----------------------------------}

  Function UpChar(AAA : char) : char;
  Function LoChar(AAA : char) : char;
  Function UpString(AAA : string) : string;
  Function LoString(AAA : string) : string;

  Function Replicate(AAA : char;Repl_num:byte) : string;
  Procedure Fill_Mem(ZZZ : pointer ; AAA : char ; Fill_num : integer);

  Function Trim (ZZZ:string) : string;
  Function RTrim(ZZZ:string) : string;
  Function LTrim(ZZZ:string) : string;
  Function Left (ZZZ:string;left_num:byte): string;
  Function Right(ZZZ:string;Right_num:byte): string;
  Function Subs (ZZZ:string;begin_pos,str_length:byte): string;

{--- CMF Music -----------------------}
  Function  CMFinit(CmfOK: Pointer): Boolean;
  Procedure CMFPlay(DataBuf: Pointer);
  Procedure CMFStop;
  Procedure CMFPause;
  Procedure CMFGoOn;

Implementation

 var
   OCB           : TextRec absolute OutPut;
   cur_para      : get_ele;
   str_get       : string[80] ;
   getbuffer     : array [1..Max_get] of get_ele ;
   PromptBuffer  : array [1..Max_prompt] of Prompt_ele;
   Date_value    : date   ;
   Real_value    : real    absolute Date_value;
   Integer_value : integer absolute Real_value;
   Longint_value : longint absolute Real_value;
   zzzzzzzzzzzzz : real;
   Error_make_num: integer;
   Decpos        : integer;
   Ins_flag      : byte;
   Edit_flag     : Boolean;


  Procedure EMPIO_Init                                       ;external;
  Procedure Box(x1,y1,x2,y2:word ; a :str_box )              ;external;
  Procedure Zoom(x1,y1,x2,y2:word ; a :str_box )             ;external;
  Procedure scroll(x1,y1,x2,y2:word;line_scroll:integer)     ;external;
  Procedure Set_Attrib(x1,y1,x2,y2:word;color:byte)          ;external;
  Procedure Fill_char(char_fill:char;Fill_count:word)        ;external;
  procedure Clear                                            ;external;
  procedure Backup_Screen                                    ;external;
  procedure Restore_Screen                                   ;external;
  Procedure Cursor_on                                        ;external;
  Procedure Cursor_off                                       ;external;
  procedure Delay(Count:word)                                ;external;
  procedure Gettime                                          ;external;

  procedure Sound(Freq:word)                                 ;external;
  procedure Sound_on                                         ;external;
  procedure Sound_off                                        ;external;

{ function  GetExcPath                                       ;external; }
  procedure GetIntVec(IntNo: Byte; var  Vector: Pointer)     ;external;
  procedure SetIntVec(IntNo: Byte; Vector: Pointer)          ;external;
  procedure EMP_VNI_LOAD                                     ;external;
  procedure EMP_VNI_UNLOAD                                   ;external;
  procedure RunAddr(Addr: Pointer)                           ;external;
{ procedure Exec(cmd, cml: String)                           ;external; }

  Procedure Gotoxy(col,row:word)                             ;external;
  Procedure TextColor(color:byte)                            ;external;
  Procedure TextBackground(color:byte)                       ;external;
  procedure ClrScr                                           ;external;
  procedure NoSound                                          ;external;

  procedure get_str(var ZZZ)                                 ;external;

  procedure Readg                                            ;external;
  procedure Disp_get                                         ;external;
  procedure getc(var ZZZ)                                    ;external;
  procedure gets(var ZZZ)                                    ;external;
  procedure geti(var ZZZ)                                    ;external;
  procedure getl(var ZZZ)                                    ;external;
  procedure getr(var ZZZ)                                    ;external;
  procedure getd(var ZZZ)                                    ;external;
  procedure pict(size,dec: word)                             ;external;
  procedure Valid(KKK : pointer)                             ;external;
  procedure SubProc(KKK : pointer)                           ;external;

  function  Inkey     :word                                  ;external;
  function  Inchar    :char                                  ;external;
  function  KeyPressed:boolean                               ;external;

  procedure WScr                                             ;external;
  procedure Write_Str                                        ;external;

  Procedure Prompt(chuoi:string)                             ;external;
  Procedure Read_Prompt                                      ;external;
  Procedure Brow(row,col,ele_size,disp_num,max_num:word;buffer:pointer);external;

  Procedure Out_To_File(file_name:string;mode:byte)          ;external;
  Procedure Out_To_screen                                    ;external;
  Procedure Eject                                            ;external;
  Procedure Reset_PRN                                        ;external;

  Function Dtoc(var Date_value: date)  :string               ;external;
  Function Day(var Date_value: date)   :integer              ;external;
  Function Month(var Date_value: date) :integer              ;external;
  Function Year(var Date_value: date)  :integer              ;external;

  Function UpChar(AAA : char) : char                         ;external;
  Function LoChar(AAA : char) : char                         ;external;
  Function UpString(AAA : string) : string                   ;external;
  Function LoString(AAA : string) : string                   ;external;
  Function Replicate(AAA : char;Repl_num:byte) : string      ;external;
  Procedure Fill_mem(ZZZ :pointer ; AAA : char ; Fill_num : integer);external;

  Function Trim(ZZZ:string) : string                         ;external;
  Function RTrim(ZZZ:string): string                         ;external;
  Function LTrim(ZZZ:string): string                         ;external;
  Function Left(ZZZ:string;left_num:byte): string            ;external;
  Function Right(ZZZ:string;Right_num:byte): string          ;external;
  Function Subs(ZZZ:string;begin_pos,str_length:byte): string;external;

{----------- CMF Music sound procedures-------------}
  Function  CMFinit(CmfOK: Pointer) : Boolean                ;external;
  Procedure CMFPlay(DataBuf: Pointer)                        ;external;
  Procedure CMFStop                                          ;external;
  Procedure CMFGoon                                          ;external;
  Procedure CMFPause                                         ;external;

  {$L IO.obj}
  {$L Get.obj}
  {$L Prompt.obj}
  {$L Brow.obj}
  {$L String.obj}
  {$L CMFMUSIC.obj}

  procedure Make_integer_str;
    begin
      str(integer_value:cur_para.size,str_get);
    end;
  procedure Make_longint_str;
    begin
      str(Longint_value:cur_para.size,str_get);
    end;
  procedure Make_real_str;
    begin
      str(real_value:cur_para.size:cur_para.dec,str_get);
    end;

  procedure Make_integer_num;
    begin
      val(str_get,integer_value,error_make_num);
    end;
  procedure Make_longint_num;
    begin
      val(str_get,Longint_value,error_make_num);
    end;
  procedure Make_real_num;
    begin
      val(str_get,real_value,error_make_num);
    end;

begin
      OCB.Handle   :=0;
      OCB.Flushfunc:=addr(write_str);
      EMPIO_Init;
end.
