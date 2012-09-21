function [window,screenRect,ifi,whichScreen]=initScreen(multisampling)
whichScreen = max(Screen('Screens'));
if nargin<1
    [window,screenRect] = Screen(whichScreen, 'OpenWindow');
else
    [window,screenRect] = Screen(whichScreen, 'OpenWindow', [], [], [], [], [], multisampling);
end
Screen('BlendFunction', window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
ifi=Screen('GetFlipInterval', window);