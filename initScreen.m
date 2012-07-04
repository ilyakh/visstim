function [window,screenRect,ifi,whichScreen]=initScreen
whichScreen = max(Screen('Screens'));
%whichScreen = 1;
[window,screenRect] = Screen(whichScreen, 'OpenWindow');
    Screen('BlendFunction', window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    ifi=Screen('GetFlipInterval', window);