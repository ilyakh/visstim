function [dio_input_channel] = initialisedio(q)
%INITIALISEDIO Intitialises NI DAQ. 
%If in testing mode, skip DAQ intialisation and return an empty string
if ~q.testingMode
    dio = digitalio('nidaq', q.deviceName);
    dio_input_channel = addline(dio, q.inputLine, q.inputPort, 'in');
else
    dio_input_channel = '';
end
end

