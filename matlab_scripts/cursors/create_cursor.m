function h = create_cursor(xloc,yl,color)
h = line([xloc,xloc],yl,'Tag','cursor','color',color,'ButtonDownFcn',@startDragFcn);

set(gcf,'WindowButtonUpFcn',@stopDragFcn);

    function startDragFcn(varargin)
        set(gcf,'WindowButtonMotionFcn',@draggingFcn);
    end

    function draggingFcn(varargin)
        pt = get(gca,'CurrentPoint');
        set(h,'XData',pt(1)*[1,1]);
    end

    function stopDragFcn(varargin)
        set(gcf,'WindowButtonMotionFcn','');
    end
end