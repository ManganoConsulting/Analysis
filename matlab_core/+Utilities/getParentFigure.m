function fh = getParentFigure(h)
    fh = h;
    while 1
       h = get(h,'Parent');
       if h == 0
           break;
       else
           fh = h;
       end  
    end
