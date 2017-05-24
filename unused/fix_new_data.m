output_dir = 'D:\Avgoustinos\Documents\MWMGEN\Damien_train1\results\figs';
[FontName, FontSize, LineWidth, Export, ExportStyle] = parse_configs;
f = figure;
set(f,'Visible','off');
for i = 1:length(my_trajectories.items)
    plot_arena(segmentation_configs);
    plot_trajectory(my_trajectories.items(i));
    export_figure(f, output_dir, sprintf('traj_%d', i), Export, ExportStyle);
    cla
end

for i = 1:length(my_trajectories.items)
    my_trajectories.items(i).points(1:3,:) = [];
end

zzz = [4 6 10 24 25 36 37 40 41 50 53 54 65 66 ...
    67 68 70 71 75 79 80 82 83 84 90 ...
    96 99 100 105 114 115 116 123 128 129 ...
    140 142 147 152 153 154 164 165 166 ...
    167 172 174 177 182 184 194 195 196 ...
    204 205 212 216 217 218 219 236 237 238 239 ...
    249 254 255 256 263 267 268 277 278 279 ...
    281 284 289 290 291 292 297 298 299 300 ...
    307 309 310 311 312 317 318 325 327 331 ...
    336 342 343 344 349 352 362 363 364 365 ...
    369 381 383 388 389 395 396 397 403 404 ...
    405 406 419 420 421 435 436 437 438 447 ...
    448 463 465 479 481 482 493 495 503 504];

for i = 1:length(zzz)
    my_trajectories.items(zzz(i)).points(1:3,:) = [];
end

output_dir = 'D:\Avgoustinos\Documents\MWMGEN\Damien_train1\results\figs3';
[FontName, FontSize, LineWidth, Export, ExportStyle] = parse_configs;
f = figure;
set(f,'Visible','off');
for i = 1:length(zzz)
    plot_arena(segmentation_configs);
    plot_trajectory(my_trajectories.items(zzz(i)));
    export_figure(f, output_dir, sprintf('traj_%d', zzz(i)), Export, ExportStyle);
    cla
end

zzz = [40,41,54,65,67,68,70,71,99,100,105,114,...
    142,172,184,236,249,263,267,281,292,300,...
    309,310,317,318,349,352,369,381,383,388,...
    389,397,405,406,420,421,435,436,438,447,...
    448,482,483,493,495];
for i = 1:length(zzz)
    my_trajectories.items(zzz(i)).points(1:3,:) = [];
end

output_dir = 'D:\Avgoustinos\Documents\MWMGEN\Damien_train1\results\figs4';
[FontName, FontSize, LineWidth, Export, ExportStyle] = parse_configs;
f = figure;
set(f,'Visible','off');
for i = 1:length(zzz)
    plot_arena(segmentation_configs);
    plot_trajectory(my_trajectories.items(zzz(i)));
    export_figure(f, output_dir, sprintf('traj_%d', zzz(i)), Export, ExportStyle);
    cla
end

zzz = [79,83,84,90,115,129,140,152,153,154,164,165,...
    182,194,195,196,204,205,216,217,218,219,...
    237,238,239,254,255,256,268,277,278,279,...
    289,290,291,297,298,299,311,312,325,327,...
    331,336,342,343,344,362,364,365,395,396,...
    403,404,419,437,463,465,481,504];
for i = 1:length(zzz)
    my_trajectories.items(zzz(i)).points(1:7,:) = [];
end


output_dir = 'D:\Avgoustinos\Documents\MWMGEN\Damien_train1\results\figs4';
[FontName, FontSize, LineWidth, Export, ExportStyle] = parse_configs;
f = figure;
set(f,'Visible','off');
for i = 1:length(zzz)
    plot_arena(segmentation_configs);
    plot_trajectory(my_trajectories.items(zzz(i)));
    export_figure(f, output_dir, sprintf('traj_%d', zzz(i)), Export, ExportStyle);
    cla
end





zzz=[41,54,65,67,99,100,114,140,142,164,172,...
    182,184,263,267,281,289,290,292,297:300,...
   309,310,312,317,325,327,331,336,344,349,...
   352,364,365,381,383,388,389,395:397,...
   403:406,419,420,421,435,436:438,447,448,...
   463,465,493,495];
for i = 1:length(zzz)
    my_trajectories.items(zzz(i)).points(1:3,:) = [];
end
output_dir = 'D:\Avgoustinos\Documents\MWMGEN\Damien_train1\results\figs5';
[FontName, FontSize, LineWidth, Export, ExportStyle] = parse_configs;
f = figure;
set(f,'Visible','off');
for i = 1:length(zzz)
    plot_arena(segmentation_configs);
    plot_trajectory(my_trajectories.items(zzz(i)));
    export_figure(f, output_dir, sprintf('traj_%d', zzz(i)), Export, ExportStyle);
    cla
end

zzz=[70,71,79,83,84,90,129,115,152,153,154,165,...
    194,195,196,204,205,216,217,218,219,237,...
    239,249,254,255,256,268,277,278,...
    279,291,311,362,504];
for i = 1:length(zzz)
    my_trajectories.items(zzz(i)).points(1:7,:) = [];
end
output_dir = 'D:\Avgoustinos\Documents\MWMGEN\Damien_train1\results\figs5';
[FontName, FontSize, LineWidth, Export, ExportStyle] = parse_configs;
f = figure;
set(f,'Visible','off');
for i = 1:length(zzz)
    plot_arena(segmentation_configs);
    plot_trajectory(my_trajectories.items(zzz(i)));
    export_figure(f, output_dir, sprintf('traj_%d', zzz(i)), Export, ExportStyle);
    cla
end

zzz = [442,343,482];
for i = 1:length(zzz)
    my_trajectories.items(zzz(i)).points(1:11,:) = [];
end
output_dir = 'D:\Avgoustinos\Documents\MWMGEN\Damien_train1\results\figs5';
[FontName, FontSize, LineWidth, Export, ExportStyle] = parse_configs;
f = figure;
set(f,'Visible','off');
for i = 1:length(zzz)
    plot_arena(segmentation_configs);
    plot_trajectory(my_trajectories.items(zzz(i)));
    export_figure(f, output_dir, sprintf('traj_%d', zzz(i)), Export, ExportStyle);
    cla
end












zzz = [41,54,65,67,99,100,114,140,142,164,172,...
    182,184,263,267,281,289,290,292,297:300,...
   309,310,312,317,325,327,331,336,344,349,...
   352,364,365,381,383,388,389,395:397,...
   403:406,419,420,421,435,436:438,447,448,...
   463,465,493,495,70,71,79,83,84,90,129,115,152,153,154,165,...
    194,195,196,204,205,216,217,218,219,237,...
    239,249,254,255,256,268,277,278,...
    279,291,311,362,504];
for i = 1:length(zzz)
    my_trajectories.items(zzz(i)).points(1:11,:) = [];
end
output_dir = 'D:\Avgoustinos\Documents\MWMGEN\Damien_train1\results\figs6';
[FontName, FontSize, LineWidth, Export, ExportStyle] = parse_configs;
f = figure;
set(f,'Visible','off');
for i = 1:length(zzz)
    plot_arena(segmentation_configs);
    plot_trajectory(my_trajectories.items(zzz(i)));
    export_figure(f, output_dir, sprintf('traj_%d', zzz(i)), Export, ExportStyle);
    cla
end














zzz = [41,54,65,67,99,100,114,140,142,164,172,...
    182,184,263,267,281,289,290,292,297:300,...
   309,310,312,317,325,327,331,336,344,349,...
   352,364,365,381,383,388,389,395:397,...
   403:406,419,420,421,435,436:438,447,448,...
   463,465,493,495,70,71,79,83,84,90,129,115,152,153,154,165,...
    194,195,196,204,205,216,217,218,219,237,...
    239,249,254,255,256,268,277,278,...
    279,291,311,362,504];
for i = 1:length(zzz)
    my_trajectories.items(zzz(i)).points(1:4,:) = [];
end
output_dir = 'D:\Avgoustinos\Documents\MWMGEN\Damien_train1\results\figs7';
[FontName, FontSize, LineWidth, Export, ExportStyle] = parse_configs;
f = figure;
set(f,'Visible','off');
for i = 1:length(zzz)
    plot_arena(segmentation_configs);
    plot_trajectory(my_trajectories.items(zzz(i)));
    export_figure(f, output_dir, sprintf('traj_%d', zzz(i)), Export, ExportStyle);
    cla
end



zzz = [300,336,381,388,396,419,435,493];
for i = 1:length(zzz)
    my_trajectories.items(zzz(i)).points(1:8,:) = [];
end
output_dir = 'D:\Avgoustinos\Documents\MWMGEN\Damien_train1\results\figs8';
[FontName, FontSize, LineWidth, Export, ExportStyle] = parse_configs;
f = figure;
set(f,'Visible','off');
for i = 1:length(zzz)
    plot_arena(segmentation_configs);
    plot_trajectory(my_trajectories.items(zzz(i)));
    export_figure(f, output_dir, sprintf('traj_%d', zzz(i)), Export, ExportStyle);
    cla
end

zzz= [300,381];
for i = 1:length(zzz)
    my_trajectories.items(zzz(i)).points(1:5,:) = [];
end
output_dir = 'D:\Avgoustinos\Documents\MWMGEN\Damien_train1\results\figs8';
[FontName, FontSize, LineWidth, Export, ExportStyle] = parse_configs;
f = figure;
set(f,'Visible','off');
for i = 1:length(zzz)
    plot_arena(segmentation_configs);
    plot_trajectory(my_trajectories.items(zzz(i)));
    export_figure(f, output_dir, sprintf('traj_%d', zzz(i)), Export, ExportStyle);
    cla
end




zzz = [442,343,482];
for i = 1:length(zzz)
    my_trajectories.items(zzz(i)).points(1:11,:) = [];
end
output_dir = 'D:\Avgoustinos\Documents\MWMGEN\Damien_train1\results\figs9';
[FontName, FontSize, LineWidth, Export, ExportStyle] = parse_configs;
f = figure;
set(f,'Visible','off');
for i = 1:length(zzz)
    plot_arena(segmentation_configs);
    plot_trajectory(my_trajectories.items(zzz(i)));
    export_figure(f, output_dir, sprintf('traj_%d', zzz(i)), Export, ExportStyle);
    cla
end