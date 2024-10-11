function PAINT

    % - - - SETUP DEL PROGRAMA - - - 

    % paleta de colores
    paleta_colores = ...
        [1 .5  0  1  0  0 .8 .6 .6;      % r                 
         1 .5  0  0  1  0 .6 .8 .6;      % g
         1 .5  0  0  0  1 .6 .6 .8]';    % b
    
    % contador para el numero de lineas
    cont_lineas = 0;
     
    % hacer que las unidades de la pantalla vayan de 0 a 1
    set(0, 'units', 'normalized');   

    % forma la ventana del programa
    % los @ le dicen al programa que se usan esas funciones
    set(gcf, ...
        'color',   [0 0 0], ...
        'menubar', 'none', ...
        'closerequestfcn',     @close_req_call,  ...
        'units',   'normalized', ...
        'numbertitle',        'off', ...
        'windowstate', 'maximized');
    
    % fija los limites de la pantalla
    set(gca, ...
        'units',    'normalized','xlim', [0 1], ...          
        'position', [0 0 1 1],   'ylim', [0 1], ...     
        'ticklen',  [0 0],       'pickableparts','none', ...
        'box',      'on');    
       
    % muestra el panel lateral
    top_panel = box( .95, .95, .05, .95,  [.15 .15 .15], [0 0 0]); 

    % crea el marco gris alrededor del lienzo
    canvas_frame(1) = box( .45,  .005, .45,  .005, [.4  .4  .4],  [.4  .4  .4]);
    canvas_frame(2) = box( .45,  .995, .45,  .005, [.4  .4  .4],  [.4  .4  .4]); 
    canvas_frame(3) = box( .005, .45,  .005, .55,  [.4  .4  .4],  [.4  .4  .4]); 
    canvas_frame(4) = box( .895, .45,  .005, .55,  [.4  .4  .4],  [.4  .4  .4]);

    % muestra el cuadro amarillo que señala el modo actual
    cuadro_modo(1) = box( .95,  .83, .05,  .0025, [1 1 0],  [1 1 0]);
    cuadro_modo(2) = box( .95,  .97, .05,  .0025, [1 1 0],  [1 1 0]); 
    cuadro_modo(3) = box( .9025, .9,  .0025, .0725,  [1 1 0],  [1 1 0]); 
    cuadro_modo(4) = box( .9975, .9,  .0025, .0725,  [1 1 0],  [1 1 0]);

    % nombres de los ficheros de audio de los colores
    files_colores = ["audios/Blanco.m4a","audios/Gris.m4a","audios/Negro.m4a","audios/Rojo.m4a","audios/Verde.m4a","audios/Azul.m4a","audios/Rojopastel.m4a","audios/Verdepastel.m4a","audios/Azulpastel.m4a"];

    % - - - INICIAR NORAXON Y PARÁMETROS DEL PAINT - - -

    %[stream_config, sensor_selection] = noraxon_stream_init('127.0.0.1', '9220');
    program_on  = 1;
    modo = 1;            % modo inicial (1 navegar, 2 pintar, 3 elegir color)
    indice_color = 3;    % indice del color inicial
    movimiento = 0.0015;  % factor de movimiento
    brush_size = 6;      % grosor del pincel
    factor_grosor = 5;   % factor de grosor

    % - - - INCIAR EL PINCEL - - - 

    active_color = paleta_colores(indice_color,:); % color inicial
    hold on; % Permite superponer gráficos en la figura actual
    pincel = rectangle('Position', [0.5-0.01, 0.5-0.01, 0.02, 0.02], ...
                       'Curvature', [1, 1], ...
                       'FaceColor', active_color); 
    hold off;

    % simbolos del panel lateral
    labels(1) = box( .95,  .90,  .035, .01,  [1 1 1], [1 1 1]); %  = 
    labels(2) = box( .95,  .75,  .035, .03,  [1 1 1], [1 1 1]); % |_|
    labels(3) = box( .95,  .60,  .045, .07,  active_color, active_color);

    % - - - BUCLE DEL PROGRAMA - - - 
    
    while program_on == 1
        % Recoger datos Noraxon
        % Data = noraxon_stream_collect(stream_config, 0.3);
        % samplingRate = 1500;

        % flexion_dcha = movmean(abs(Data(1).samples(:)),samplingRate);
        % extension_dcha = movmean(abs(Data(2).samples(:)),samplingRate);
        % flexion_izq = movmean(abs(Data(3).samples(:)),samplingRate);
        % extension_izq = movmean(abs(Data(4).samples(:)),samplingRate);

        % Recoger datos de un archivo EMG
        file = load('EMG 2 channel Wrist Flex_Ext_Raw.mat');
        samplingRate = file.samplingRate;  % Accede a la variable deseada desde la estructura
        Data = file.Data;

        flexion_dcha = movmean(abs(Data{2}),samplingRate);
        extension_dcha = movmean(abs(Data{3}),samplingRate);
        flexion_izq = movmean(abs(Data{2}),samplingRate);
        extension_izq = movmean(abs(Data{3}),samplingRate);

        % booleanos
        umbral_flexion = 20;
        umbral_extension = 18;
               
        cocontraccion_dcha = false;
        cocontraccion_izq = false;

        cambio_dcha = false;
        cambio_izq = false;

        dibujando_dcha = false;
        dibujando_izq = false;

        % bucle para el data       
        for i = 1 : length(flexion_izq)

            % obtener la posición actual del pincel
            pincel_pos = get(pincel, 'Position'); 
            
            % actualiza el color del puncel
            set(pincel, ...
                'FaceColor', active_color);

            % DERECHA
            if (flexion_dcha(i)>umbral_flexion && extension_dcha(i)>umbral_extension)
                % COCONTRACCION DCHA
                if (~cocontraccion_dcha)
                    cocontraccion_dcha = true;
                    if (modo==1) % CAMBIO A MODO PINCEL
                        modo = 2;

                        % eliminar el cuadro amarillo del anterior modo y crear uno nuevo
                        delete(findobj(cuadro_modo));
                        
                        cuadro_modo(1) = box( .95,   .68,  .05,   .0025,  [1 1 0],  [1 1 0]);
                        cuadro_modo(2) = box( .95,   .82,  .05,   .0025,  [1 1 0],  [1 1 0]); 
                        cuadro_modo(3) = box( .9025, .75,  .0025, .0725,  [1 1 0],  [1 1 0]); 
                        cuadro_modo(4) = box( .9975, .75,  .0025, .0725,  [1 1 0],  [1 1 0]);

                        % AUDIO
                        filename = 'audios/Pintar.m4a';
                        [y, Fs] = audioread(filename);
                        player = audioplayer(y, Fs);
                        play(player);
                        pause(2);
                        stop(player);
                        
                    elseif (modo==2) % CAMBIO A MODO COLOR
                        modo = 3;

                        % eliminar el cuadro amarillo del anterior modo y crear uno nuevo
                        delete(findobj(cuadro_modo));
                        cuadro_modo(1) = box( .95,  .53, .05,  .0025, [1 1 0],  [1 1 0]);
                        cuadro_modo(2) = box( .95,  .67, .05,  .0025, [1 1 0],  [1 1 0]); 
                        cuadro_modo(3) = box( .9025, .6,  .0025, .0725,  [1 1 0],  [1 1 0]); 
                        cuadro_modo(4) = box( .9975, .6,  .0025, .0725,  [1 1 0],  [1 1 0]);

                        % AUDIO
                        filename = 'audios/Colores.m4a';
                        [y, Fs] = audioread(filename);
                        player = audioplayer(y, Fs);
                        play(player);
                        pause(3.5);
                        stop(player);
                        
                        % desplegar el marco del menú de colores
                        cuadro_colores(1) = box( .45,   .746, .20,  .005, [.4  .4  .4],  [.4  .4  .4]);
                        cuadro_colores(2) = box( .45,   .254, .20,  .005, [.4  .4  .4],  [.4  .4  .4]); 
                        cuadro_colores(3) = box( .255,  .5,  .005, .24,  [.4  .4  .4],  [.4  .4  .4]); 
                        cuadro_colores(4) = box( .645,  .5,  .005, .24,  [.4  .4  .4],  [.4  .4  .4]);
                    
                        % muestra los rectangulos de colores en la pantalla
                        color = 1;
                        for fila = 1 : 3
                            for columna = 1 : 3
                                colores(color) = box( .324 + .126*(columna - 1), .66 - .16*(fila - 1), .063, .08, ...
                                    paleta_colores(color,:), 'black');
                                color = color + 1;
                            end
                        end
                        
                        % crea el cuadro amarillo que indica el color
                        for fila = 1:3
                            for columna = 1:3
                                if (columna*fila + (3-columna)*(fila-1)) == indice_color 
                                    break;
                                end
                            end
                            if (columna*fila + (3-columna)*(fila-1)) == indice_color 
                                break;
                            end
                        end
                
                        cuadro_color(1) = box( .325 + (columna - 1)*.125, .7375 - (fila - 1)*.161,   .0625, .0025, [1  1  0],  [1  1  0]);
                        cuadro_color(2) = box( .325 + (columna - 1)*.125, .5845 - (fila - 1)*.1615,  .0625, .0025, [1  1  0],  [1  1  0]); 
                        cuadro_color(3) = box( .263 + (columna - 1)*.126, .66   - (fila - 1)*.16,    .0025, .079,  [1  1  0],  [1  1  0]); 
                        cuadro_color(4) = box( .385 + (columna - 1)*.126, .66   - (fila - 1)*.16,    .0025, .079,  [1  1  0],  [1  1  0]);
                

                    else % CAMBIA A MODO NAVEGAR
                        % elimina todo lo creado en el modo 2
                        delete(findobj(cuadro_colores));
                        delete(findobj(colores));
                        delete(findobj(cuadro_color));
                        
                        modo = 1;

                        % eliminar el cuadro amarillo del anterior modo y crear uno nuevo
                        delete(findobj(cuadro_modo));
                        
                        cuadro_modo(1) = box( .95,   .83, .05,   .0025,  [1 1 0],  [1 1 0]);
                        cuadro_modo(2) = box( .95,   .97, .05,   .0025,  [1 1 0],  [1 1 0]); 
                        cuadro_modo(3) = box( .9025, .9,  .0025, .0725,  [1 1 0],  [1 1 0]); 
                        cuadro_modo(4) = box( .9975, .9,  .0025, .0725,  [1 1 0],  [1 1 0]);

                        % AUDIO
                        filename = 'audios/Navegar.m4a';
                        [y, Fs] = audioread(filename);
                        player = audioplayer(y, Fs);
                        play(player);
                        pause(3); 
                        stop(player);

                    end
                end


            else
                % NO COCONTRACCION DERECHA
                cocontraccion_dcha = false;
                if (flexion_dcha(i)>umbral_flexion && extension_dcha(i)<umbral_extension)
                    if (modo == 3 && ~cambio_dcha) % MOVER DERECHA POR PANEL DE COLORES
                        cambio_dcha = true;
                        if (indice_color == 9)
                            indice_color = 1;
                        else
                            indice_color = indice_color + 1;
                        end

                        % eliminar el cuadro amarillo del anterior color y crear uno nuevo
                        delete(findobj(cuadro_color));
                        dibujar_cuadro_color(indice_color);

                        % AUDIO
                        filename = files_colores(indice_color);
                        [y, Fs] = audioread(filename);
                        player = audioplayer(y, Fs);
                        play(player);
                        pause(2);
                        stop(player);
                        
                    else
                        if (modo == 2 && pincel_pos(1) + pincel_pos(3) < .89) % MOVER DERECHA PINCEL
                            pincel_pos(1) = pincel_pos(1) + movimiento; % Mover hacia la derecha dentro de los límites

                            if (~dibujando_dcha)
                                % crea una nueva línea
                                dibujando_dcha = true;
                                cont_lineas = cont_lineas + 1;
                                brush_line(cont_lineas) = animatedline( ...
                                    'linewidth', brush_size, 'color', active_color);
                            end

                            % actualiza el grosor del pincel
                            set( brush_line( cont_lineas), 'linewidth', brush_size);

                            % añade puntos a la línea ya creada
                            addpoints( brush_line( cont_lineas), pincel_pos(1) + 0.01, pincel_pos(2) + 0.01);

                            % hace que el pincel quede por encima de la linea
                            uistack(pincel, 'top');

                        elseif (modo == 1 && pincel_pos(1) + pincel_pos(3) < .89) % MOVER DERECHA RATON
                            pincel_pos(1) = pincel_pos(1) + movimiento; % Mover hacia la derecha dentro de los límites
                        
                        end
                    end
                elseif (flexion_dcha(i)<umbral_flexion && extension_dcha(i)>umbral_extension)
                    if (modo == 3 && ~cambio_dcha) % MOVER IZQUIERDA POR PANEL DE COLORES
                        cambio_dcha = true;
                        if (indice_color == 1)
                            indice_color = 9;
                        else
                            indice_color = indice_color - 1;
                        end
                        
                        % eliminar el cuadro amarillo del anterior color y crear uno nuevo
                        delete(findobj(cuadro_color));
                        dibujar_cuadro_color(indice_color);

                        % AUDIO
                        filename = files_colores(indice_color);
                        [y, Fs] = audioread(filename);
                        player = audioplayer(y, Fs);
                        play(player);
                        pause(2); 
                        stop(player);

                    else 
                        if (modo == 2 && pincel_pos(1) > .01) % MOVER IZQUIERDA PINCEL
                            pincel_pos(1) = pincel_pos(1) - movimiento; % Mover hacia la izquierda dentro de los límites

                            if (~dibujando_dcha)
                                % crea una nueva línea
                                dibujando_dcha = true;
                                cont_lineas = cont_lineas + 1;
                                brush_line(cont_lineas) = animatedline( ...
                                    'linewidth', brush_size, 'color', active_color);
                            end

                            % actualiza el grosor del pincel
                            set( brush_line( cont_lineas), 'linewidth', brush_size);

                            % añade puntos a la línea ya creada
                            addpoints( brush_line( cont_lineas), pincel_pos(1) + 0.01, pincel_pos(2) + 0.01);

                            % hace que el pincel quede por encima de la linea
                            uistack(pincel, 'top');

                        elseif (modo == 1 && pincel_pos(1) > .01) % MOVER IZQUIERDA RATON
                            pincel_pos(1) = pincel_pos(1) - movimiento; % Mover hacia la izquierda dentro de los límites

                        end
                    end
                else
                    % NO MOVERSE
                    cambio_dcha = false;
                    dibujando_dcha = false;
                end
            end
    




            %IZQUIERDA
            if (flexion_izq(i)>umbral_flexion && extension_izq(i)>umbral_extension)
                %COCONTRACCION IZQ
                if (~cocontraccion_izq)
                    cocontraccion_izq = true;
                    if (modo == 1) % GUARDAR JPG

                        % AUDIO
                        filename = 'audios/Guardar.m4a';
                        [y, Fs] = audioread(filename);
                        player = audioplayer(y, Fs);
                        play(player);
                        pause(3);
                        stop(player);

                        % guardado del archivo en .jpg
                        image_data = getfield( getframe( gcf),'cdata');
                        image_file = uiputfile({'paint.jpg'});
                        if image_file ~= 0
                            imwrite(image_data, image_file);  
                        end
                        

                    elseif (modo == 2) % CAMBIAR GROSOR
                        brush_size = brush_size + factor_grosor;
                        factor_grosor = factor_grosor * (-1);

                        % AUDIO
                        if (factor_grosor > 0)
                            filename = 'audios/Pinfino.m4a';
                        else
                            filename = 'audios/Pingrueso.m4a';
                        end
                        [y, Fs] = audioread(filename);
                        player = audioplayer(y, Fs);
                        play(player);
                        pause(2.5);
                        stop(player);

                    else % SELECCIONAR COLOR
                        % actualiza el nuevo color
                        active_color = paleta_colores(indice_color,:);
                        set(pincel, 'FaceColor', active_color);

                        % elimina el color del cuadrado en el panel lateral y crea otro con el color actualizado
                        delete(labels(3));
                        labels(3) = box( .95,  .60,  .045, .07,  active_color, active_color);

                        % hace que el cuadro amarillo que indica el modo quede por encima del nuevo rectangulo de color creado
                        uistack(cuadro_modo(1), 'top');
                        uistack(cuadro_modo(2), 'top');
                        uistack(cuadro_modo(3), 'top');
                        uistack(cuadro_modo(4), 'top');

                    end
                end


            else
                %NO COCONTRACCION IZQUIERDA
                cocontraccion_izq = false;
                if (flexion_izq(i)>umbral_flexion && extension_izq(i)<umbral_extension)
                    if (modo == 1 && pincel_pos(2) + pincel_pos(4) < 0.9) % MOVER ARRIBA RATON
                        pincel_pos(2) = pincel_pos(2) + movimiento; % Mover hacia arriba dentro de los límites

                    elseif (modo == 2 && pincel_pos(2) + pincel_pos(4) < 0.9) % MOVER ARRIBA PINCEL
                        pincel_pos(2) = pincel_pos(2) + movimiento; % Mover hacia arriba dentro de los límites

                        if (~dibujando_izq)
                            % crea una nueva línea
                            dibujando_izq = true;
                            cont_lineas = cont_lineas + 1;
                            brush_line(cont_lineas) = animatedline( ...
                                'linewidth', brush_size, 'color', active_color);
                        end

                        % actualiza el grosor del pincel
                        set( brush_line( cont_lineas), 'linewidth', brush_size);

                        % añade puntos a la línea ya creada
                        addpoints( brush_line( cont_lineas), pincel_pos(1) + 0.01, pincel_pos(2) + 0.01);

                        % hace que el pincel quede por encima de la linea
                        uistack(pincel, 'top');

                    elseif(modo == 3 && ~cambio_izq) % MOVER ARRIBA POR PANEL DE COLORES
                        cambio_izq = true;
                        if (indice_color <= 3)
                            indice_color = indice_color + 6;
                        else
                            indice_color = indice_color - 3;
                        end
                        
                        % eliminar el cuadro amarillo del anterior color y crear uno nuevo
                        delete(findobj(cuadro_color));
                        dibujar_cuadro_color(indice_color);

                        % AUDIO
                        filename = files_colores(indice_color);
                        [y, Fs] = audioread(filename);
                        player = audioplayer(y, Fs);
                        play(player);
                        pause(2);
                        stop(player);

                    end

                elseif (flexion_izq(i)<umbral_flexion && extension_izq(i)>umbral_extension)
                    if (modo == 1 && pincel_pos(2) > 0.01) % MOVER ABAJO RATON
                        pincel_pos(2) = pincel_pos(2) - movimiento; % Mover hacia abajo dentro de los límites

                    elseif (modo == 2 && pincel_pos(2) > 0.01) % MOVER ABAJO PINCEL
                        pincel_pos(2) = pincel_pos(2) - movimiento; % Mover hacia abajo dentro de los límites

                        if (~dibujando_izq)
                            % crea una nueva línea
                            dibujando_izq = true;
                            cont_lineas = cont_lineas + 1;
                            brush_line(cont_lineas) = animatedline( ...
                                'linewidth', brush_size, 'color', active_color);
                        end

                        % actualiza el grosor del pincel
                        set( brush_line( cont_lineas), 'linewidth', brush_size);

                        % añade puntos a la línea ya creada
                        addpoints( brush_line( cont_lineas), pincel_pos(1) + 0.01, pincel_pos(2) + 0.01);

                        % eliminar el cuadro amarillo del anterior color y crear uno nuevo
                        uistack(pincel, 'top');

                    elseif (modo == 3 && ~cambio_izq) % MOVER ABAJO POR PANEL DE COLORES
                        cambio_izq = true;
                        if (indice_color >= 7)
                            indice_color = indice_color - 6;
                        else
                            indice_color = indice_color + 3;
                        end
                        
                        delete(findobj(cuadro_color));
                        dibujar_cuadro_color(indice_color);

                        % AUDIO
                        filename = files_colores(indice_color);
                        [y, Fs] = audioread(filename);
                        player = audioplayer(y, Fs);
                        play(player);
                        pause(2);
                        stop(player);

                    end
                else
                    % NO MOVERSE
                    cambio_izq = false;
                    dibujando_izq = false;
                end
            end


            % Actualizar la posición del pincel
            set(pincel, 'Position', pincel_pos); 

            % pinta
            drawnow;
            
            if (~program_on)
                % elimina la ventana del programa
                delete(gcf);
                break;
            end
        end
    end
    

    % - - - Functions - - - 
    
    % genera un rectangulo
    % x esla posicion izquierda derecha, siendo 1 derecha del todo y 0
    % izquierda
    % y es la posicion arriba abajo, siendo 1 arriba del todo y 0 abajo
    % w es lo largo del rectángulo (lados)
    % h es lo ancho del rectángulo (abajo/arriba)
    function b = box(x, y, w, h, face_color, edge_color)
        b = patch( ...
            'vertices', [x-w, x-w, x+w, x+w; y-h, y+h, y+h, y-h]', ...
            'faces', [1, 2, 3, 4], ...
            'facecolor', face_color, ...
            'edgecolor', edge_color);
    end

    function dibujar_cuadro_color(indice_color)
        for fila = 1:3
            for columna = 1:3
                if (columna*fila + (3-columna)*(fila-1)) == indice_color 
                    break;
                end
            end
            if (columna*fila + (3-columna)*(fila-1)) == indice_color 
                break;
            end
        end

        cuadro_color(1) = box( .325 + (columna - 1)*.125, .7375 - (fila - 1)*.161,   .0625, .0025, [1  1  0],  [1  1  0]);
        cuadro_color(2) = box( .325 + (columna - 1)*.125, .5845 - (fila - 1)*.161,   .0625, .0025, [1  1  0],  [1  1  0]); 
        cuadro_color(3) = box( .263 + (columna - 1)*.126, .66   - (fila - 1)*.16,    .0025, .079,  [1  1  0],  [1  1  0]); 
        cuadro_color(4) = box( .385 + (columna - 1)*.126, .66   - (fila - 1)*.16,    .0025, .079,  [1  1  0],  [1  1  0]);
    end
    
   function close_req_call(~,~)
        program_on = 0;
    end
end