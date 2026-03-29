function div = divergence_op(px, py)
% Divergence operator corresponding to grad_op

divx = [px(:,end) - px(:,1), -diff(px,1,2)];
divy = [py(end,:) - py(1,:); -diff(py,1,1)];

div = divx + divy;

end