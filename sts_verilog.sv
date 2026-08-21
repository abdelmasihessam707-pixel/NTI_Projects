
module test_1;

int counter_1 = 0;
int counter_2 = 0;

int arr[] = {9,7,4,6,2,8,6,5};
int od[$],evn[$];
initial begin
  for (int i = 0; i < arr.size(); i++)
  begin
 
   if ( arr[i] % 2 == 0 )
    begin
      od[counter_1] = arr[i] ;
      counter_1 ++ ; 
    end else 
       begin
        evn[counter_2] = arr[i] ;
        counter_2 ++ ; 
       end
  end
    $display("Even Array : %p" , evn);
    $display("Odd Array  : %p" , od);
end
  endmodule
//==================================================================================================
module test_2;

int counter_1 = 0;
int counter_0 = 0;
int arr[] = '{1,1,0,1,1,1,1,0,0,0,1};
//int ones[$],zeros[$];
initial begin
  for (int i = 0; i < arr.size(); i++)
  begin
 
   if ( arr[i] == 1 )
    begin
      //ones[counter_1] = arr[i] ;
      counter_1 ++ ; 
    end else 
       begin
       // zeros[counter_0] = arr[i] ;
        counter_0 ++ ; 
       end
  end
  if(counter_0 > counter_1 )
  $display("MAX. consecutive number (0) -> %0d " , counter_0 );
  else if(counter_0 < counter_1 )
  $display("MAX. consecutive number (1) -> %0d " , counter_1 );
end
endmodule
//==================================================================================================
module test_3;

  int arr[5] = '{45, 34, 67, 89, 78};
  int len = 5;

  initial begin
    int max1;
    int max2;

    if (arr[0] > arr[1]) 
    begin
      max1 = arr[0];
      max2 = arr[1];
    end else 
      begin
      max1 = arr[1];
      max2 = arr[0];
      end

     for (int i = 2; i < len; i++) 
      begin
      if (arr[i] > max1) 
      begin
        max2 = max1; 
        max1 = arr[i]; 
      end else if ( (arr[i] > max2 ) && ( arr[i] != max1 ) ) 
        begin
        max2 = arr[i]; 
        end
      end
    $display("Second Max: %0d", max2);
  end

endmodule

//==================================================================================================
module test_4;

  int arr[] = '{8, 3, 3, 4, 5, 6, 3, 5, 4, 6, 8, 7, 6, 4, 3, 5, 6};
  int check[$];
  int len = arr.size();
  int count;

  initial begin
 
    for (int k = 0; k < len; k++) 
      begin
      check[k] = 0;
      end

      for (int i = 0; i < len; i++) 
      begin

      if (check[i] == 1) 
      begin
        continue;
      end

      count = 1;

        for (int j = i + 1; j < len; j++) 
        begin
        if (arr[i] == arr[j]) begin
          count = count ++;
          check[j] = 1;
        end
        end

      $display("%0d --> %0d", arr[i], count);
     end

  end
endmodule









