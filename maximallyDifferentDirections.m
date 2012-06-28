function directions = maximallyDifferentDirections(n)

directions=zeros(1, n);

directions(1) = 0;

switch n
    case 2
        directions(2) = 2;
    case 3
        directions(2) = 2;
        directions(3) = 3;
    otherwise
        jump180 = floor (n/2);
        for i=2:n
            trial =mod(directions(i-1)+jump180+1, n);
            if find(directions == trial)
                trial = trial+1;
            end
            directions(i) = trial;
        end
end

directions = directions+1;

