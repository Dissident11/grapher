--screen dimensions
screen_width = pesto.window.getWidth()
screen_height = pesto.window.getHeight()
center_x = screen_width / 2
center_y = screen_height / 2

--math utilities
sin = math.sin
cos = math.cos
tan = math.tan
floor = math.floor
abs = math.abs
pi = math.pi
origin = {0, 0}

function sign(n)
    if n > 0 then
        return 1
    elseif n < 0 then
        return -1
    else
        return 0
    end
end

function previous_integer_d(n)
    return abs(n - floor(n)) 
end

function round(n)
    return floor(n + 0.5)
end

--math modes
auto_slider = true
rotation_enabled = false
draw_lines = false
draw_points = true
even_function_mode = false
odd_function_mode = false
show_axis = false

--variables for the slider
a = 0
b = 1

--zoom
zooms = {1, 2, 3, 4, 5}
zoom_index = 1
zoom = zooms[zoom_index]
dx = 1 / zoom --the width of a pixel based on the zoom
rounding = dx / 2
w_pressed = false
s_pressed = false

function pesto.update(dt)

    --zoom in
    if pesto.keyboard.isDown("w") and w_pressed == false and zoom_index < #zooms then
        zoom_index = zoom_index + 1
        w_pressed = true
    end
    if not pesto.keyboard.isDown("w") then
        w_pressed = false
    end

    --zoom out
    if pesto.keyboard.isDown("s") and s_pressed == false and zoom_index > 1 then
        zoom_index = zoom_index - 1
        s_pressed = true
    end
    if not pesto.keyboard.isDown("s") then
        s_pressed = false
    end

    --zoom
    zoom = zooms[zoom_index]
    dx = 1 / zoom
    rounding = dx / 2

    --slider, can be done in lots of ways
    if auto_slider then
        if a > 7 then
            b = -1
        elseif a < -7 then
            b = 1
        end

        a = a + b*0.01
    end

    --graph parameters
    points = {}
    graph_points = {}
    range = {-3, 3}
    step = 1

    --create all graph points
    for x = range[1], range[2], (step / zoom) do
        y = 10*sin(x/10) --y = f(x)
        if zoom == 1 then
            y = round(y) --rounding the y to the closest integer, by default it's made with floor
        else   
            adding = round(previous_integer_d(y) / dx) --rounding y to the closest point
            y = floor(y) + adding * dx
        end    
        --distance with respect to a fixed point
        distance = math.sqrt((x - origin[1])^2 + (y - origin[2])^2)

        --angle of rotation
        if rotation_enabled then
            x1, y1 = x, y
            alpha = a*distance*10
            alpha = alpha/180 * pi

            --rotation equations of a point of an angle with respect to the origin
            x = x1*cos(alpha) - y1*sin(alpha)
            y= x1*sin(alpha) + y1*cos(alpha)
        end

        table.insert(graph_points, {x, y})

        if zoom ~= 1 then
            x = x * zoom
            y = y * zoom
        end
        
        --convert x and y from graph to screen coords
        screen_x = center_x + x
        screen_y = center_y - y

        --add new point to the graph
        new_point = {screen_x, screen_y}
        table.insert(points, new_point)
    end

end

function pesto.draw()

    pesto.graphics.text(#points, 1, 1)
    pesto.graphics.text(zoom, 1, 15)

    for v=1, #points, 1 do
        pesto.graphics.text((graph_points[v][1].. " ".. graph_points[v][2]), 1, 20 + (v)*15)
        pesto.graphics.text((points[v][1].. " ".. points[v][2]), 700, 20 + (v)*15)
    end

    pesto.graphics.text( -0.3 + 0.3, 10, 20)


    --x and y axis
    if show_axis then
        pesto.graphics.rectangle(center_x, 0, 1, screen_height)
        pesto.graphics.rectangle(0, center_y, screen_width, 1)
    end

    --draw all points
    if draw_points then
        for _, point in pairs(points) do
            pesto.graphics.rectangle(point[1], point[2], 1, 1)
        end
    end

    --draw lines to connect points, might be not so useful
    --moving the vertex from which the line are drown to make graph better looking and simmetric in some cases
    if draw_lines then
        
        --use with even function, of course
        if even_function_mode then
            for i = 1, #points - 1, 1 do
                if points[i][1] < center_x and points[i+1][1] <= center_x then
                    pesto.graphics.line(points[i][1], points[i][2], points[i + 1][1], points[i + 1][2])
                elseif points[i][1] >= center_x and points[i+1][1] > center_x then
                    pesto.graphics.line(points[i][1] + 1, points[i][2], points[i + 1][1] + 1, points[i + 1][2])
                end
            end
        
        --use with odd function, but not with all as for some it may just worsen the graph
        elseif odd_function_mode then
            for i = 1, #points - 1, 1 do
                if points[i][1] < center_x and points[i+1][1] <= center_x then
                    pesto.graphics.line(points[i][1], points[i][2], points[i + 1][1], points[i + 1][2])
                elseif points[i][1] >= center_x and points[i+1][1] > center_x then
                    pesto.graphics.line(points[i][1] + 1, points[i][2] + 1, points[i + 1][1] + 1, points[i + 1][2] + 1)
                end
            end

        else
            for i = 1, #points - 1, 1 do
                pesto.graphics.line(points[i][1], points[i][2], points[i + 1][1], points[i + 1][2])
            end
        end
    end
end
