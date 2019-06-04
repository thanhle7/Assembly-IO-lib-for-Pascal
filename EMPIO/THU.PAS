{$M $4000,0,0 }   { 16K stack, no heap }
uses EMPio;
var
     d: date;
begin
     clrscr;
     d := empty_date;
     write('Ngay: '); getd(d);
     readg;
     row := row + 1;
     writeln(d.year, ' ', d.month, ' ', d.day, '.');
end.