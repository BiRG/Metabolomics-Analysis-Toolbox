function broken = block_broken_image( in )
%Breaks in into 8x8 blocks, separating by black lines

zs=size(in,3); % Z size
xs=size(in,2); % X size
ys=size(in,1); % Y size
broken=uint8(zeros(ys+floor((ys-1)/8), xs+floor((xs-1)/8), zs));
for y=1:ys
    for x=1:xs
        broken(y+floor((y-1)/8), x+floor((x-1)/8),:)=in(y,x,:);
    end
end

end

