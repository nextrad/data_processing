 function [data, reference, params, node_file, reference_file] = single_node_reader(reference_directory, synth_dir, synth_refernce_on, ref_samples, ref_length, node_folder, node_samples)
     
    ops = 'windows';
    if strcmp(ops,'windows')
        os = '\';   
    else
        os = '/';
    end
    
    nextrad_ini_location = [node_folder os 'NeXtRAD.ini'];
    
    disp('Reading Header File');

    fid = fopen(nextrad_ini_location,'r');
    while 1
        tline = fgetl(fid);
    
         if strfind(tline, 'NUM_PRIS =')>0
            num_pri = str2double(tline(12:end));
        end
         
        
        if strfind(tline, 'SAMPLES_PER_PRI =')>0
            range_samples = str2double(tline(19:end));
        end
         
         if strfind(tline, 'WAVEFORM_INDEX = ')>0
            ref_index = str2double(tline(18:end));
        end
        
        if strfind(tline, 'PULSES = ')>0
            s = (tline(11:end));
            
        end
        
        if strfind(tline, 'ADC_CHANNEL = ')>0
            adc_chan = str2double((tline(15:end)));          
        end
        
        if ~ischar(tline)
           break
        end
    end
    count=0;
    for i = 1:length(s)
        if (s(i)==',') && count == 2
            mode = str2double(s(i-1));
            count = count + 1;
        end
        if (s(i)==',') && count == 1
            pri = str2double(s(in+1:i-1));
            count = count + 1;
        end
        if (s(i)==',') && count == 0
            pulse_length = str2double(s(1:i-1));
            in = i;
            count = count + 1;
        end
    end
    
    temp_fix =1;
    if temp_fix 
         if ref_index == 1
            pulse_length = 0.5;
            pulse_length_str = '0_5';
         end
         if ref_index == 2
            pulse_length = 1;
            pulse_length = '1';
         end
         if ref_index == 3
            pulse_length = 3;
            pulse_length_str = '3';
         end 
        if ref_index == 4
             pulse_length = 5; 
             pulse_length_str = '5';
         end
         if ref_index == 5
             pulse_length = 10;
             pulse_length_str = '10';
         end  
    end
    
    if (mode==0) 
        reference_file = dir([reference_directory os 'L' num2str(pulse_length) '.dat']);
        node_file = dir([node_folder os '*0.dat' ]);
        band = 'L';
        TXpol = 'V';
        RXpol = 'V';
    end
    
    if (mode==1) 
        reference_file = dir([reference_directory os 'L' num2str(pulse_length) '.dat']);
        node_file = dir([node_folder os '*0.dat' ]);   
        band = 'L';
        TXpol = 'V';
        RXpol = 'H';
    end
    
    if (mode==2) 
        reference_file = dir([reference_directory os 'L' num2str(pulse_length) '.dat']);
        node_file = dir([node_folder os '*0.dat' ]);
        band = 'L';
        TXpol = 'H';
        RXpol = 'V';
    end
    
    if (mode==3) 
        reference_file = dir([reference_directory os 'L' num2str(pulse_length) '.dat']);
        node_file = dir([node_folder os '*0.dat' ]);
        band = 'L';
        TXpol = 'H';
        RXpol = 'H';
    end
        
    if (mode==4) 
        reference_file = dir([reference_directory os 'X' num2str(pulse_length) '.dat']);
        node_file = dir([node_folder os '*1.dat' ]);
        band = 'X';
        TXpol = 'V';
        RXpol = 'V/H';
    end
       
    if (mode==5) 
        reference_file = dir([reference_directory os 'X' num2str(pulse_length) '.dat']);
        node_file = dir([node_folder os '*2.dat' ]);
        band = 'X';
        TXpol = 'H';
        RXpol = 'V/H';
    end 
   
    pri = pri*1e-6;
    prf = floor(1/pri);   
    
    params = struct('num_pri',num_pri,'mode',mode,'pri',pri,'prf',prf,'range_samples',range_samples,'pulse_len',pulse_length,'band',band,'TXpol',TXpol,'RXpol',RXpol);
    
    if synth_refernce_on
        
        reference = load([synth_dir os 'RefPulse_' band 'band_' pulse_length_str 'us.mat']);
        reference = reference.Ref_sig;
        disp(['Using Synthetic Reference: ' 'RefPulse_' band 'band_' pulse_length_str 'us.mat'])
    else     
        ref = [reference_directory os reference_file.name];
        fir = fopen(ref,'r');
        Datar = fread(fir, ref_samples,'int16');
        fclose(fir);
        D_Cr = Datar(1:2:end) + 1i*Datar(2:2:end);    
        reference = D_Cr(1:ref_length); 
    end
    
    node = [node_folder os node_file.name];
    fid = fopen(node,'r');
    data = fread(fid, node_samples,'int16');
    fclose(fid);
    data = data(1:2:end) + 1i*data(2:2:end);    %Data node0 Array
 
 end