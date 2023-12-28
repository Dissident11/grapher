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
show_axis = true

--variables for the slider
a = 0
b = 1

--zoom
zooms = {0.1, 0.25, 0.5, 0.75, 0.8, 1, 2, 3, 4, 5, 8, 10}
zoom_index = 6
zoom = zooms[zoom_index]
d = 1 / zoom --the width of a pixel based on the zoom
rounding = d / 2
w_pressed = false
s_pressed = false

--offsetting the graph
dx = 0
dy = 0
x_increment = 5
y_increment = 5

function pesto.update(dt)

    --zoom in
    if pesto.keyboard.isDown("up") and up_pressed == false and zoom_index < #zooms then
        zoom_index = zoom_index + 1
        up_pressed = true
    end
    if not pesto.keyboard.isDown("up") then
        up_pressed = false
    end

    --zoom out
    if pesto.keyboard.isDown("down") and down_pressed == false and zoom_index > 1 then
        zoom_index = zoom_index - 1
        down_pressed = true
    end
    if not pesto.keyboard.isDown("down") then
        down_pressed = false
    end

    --zoom
    zoom = zooms[zoom_index]
    d = 1 / zoom
    rounding = d / 2

    --slider, can be done in lots of ways
    if auto_slider then
        if a > 7 then
            b = -1
        elseif a < -7 then
            b = 1
        end

        a = a + b*0.01
    end

    --offset
    dx = 0
    dy = 0

    --offset up
    if pesto.keyboard.isDown("w") and w_pressed == false then
        dy = dy - y_increment
        w_pressed = true
    end
    if not pesto.keyboard.isDown("w") then
        w_pressed = false
    end

    --offset down
    if pesto.keyboard.isDown("s") and s_pressed == false then
        dy = dy + y_increment 
        s_pressed = true
    end
    if not pesto.keyboard.isDown("s") then
        s_pressed = false
    end

    --offset left
    if pesto.keyboard.isDown("a") and a_pressed == false then
        dx = dx - x_increment
        a_pressed = true
    end
    if not pesto.keyboard.isDown("a") then
        a_pressed = false
    end

    --offset right
    if pesto.keyboard.isDown("d") and d_pressed == false then
        dx = dx + x_increment
        d_pressed = true
    end
    if not pesto.keyboard.isDown("d") then
        d_pressed = false
    end

    --reset offset
    if pesto.mouse.isPressed(2) then
        center_x = screen_width / 2
        center_y = screen_height / 2
    end


    --offsetting the axes
    center_x = center_x + dx
    center_y = center_y + dy

    --graph parameters
    points = {}
    graph_points = {}
    range = {-1000, 1000}
    step = 1

    --create all graph points
    for x = range[1], range[2], (step / zoom) do
        y = 10*sin(x/10) --y = f(x)
        if zoom == 1 then
            y = round(y) --rounding the y to the closest integer, by default it's made with floor
        else   
            adding = round(previous_integer_d(y) / d) --rounding y to the closest point
            y = floor(y) + adding * d
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

    --show zoom
    pesto.graphics.text("ZOOM: ".. (zoom * 100).. "%", 1, 1)

    --x and y axes
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
        --lines between points are drown from and to top-left corner before origin, from and to top-right corner after it
        if even_function_mode then
            for i = 1, #points - 1, 1 do
                if points[i][1] < center_x and points[i+1][1] <= center_x then
                    pesto.graphics.line(points[i][1], points[i][2], points[i + 1][1], points[i + 1][2])
                elseif points[i][1] >= center_x and points[i+1][1] > center_x then
                    pesto.graphics.line(points[i][1] + 1, points[i][2], points[i + 1][1] + 1, points[i + 1][2])
                end
            end
        
        --use with odd function, but not with all as for some it may just worsen the graph
        --lines between points are drown from and to top-left corner before origin, from and to bottom-right corner after it
        elseif odd_function_mode then
            for i = 1, #points - 1, 1 do
                if points[i][1] < center_x and points[i+1][1] <= center_x then
                    pesto.graphics.line(points[i][1], points[i][2], points[i + 1][1], points[i + 1][2])
                elseif points[i][1] >= center_x and points[i+1][1] > center_x then
                    pesto.graphics.line(points[i][1] + 1, points[i][2] + 1, points[i + 1][1] + 1, points[i + 1][2] + 1)
                end
            end
        
        --normal way with which lines are drown, from and to every top-left corner of points
        else
            for i = 1, #points - 1, 1 do
                pesto.graphics.line(points[i][1], points[i][2], points[i + 1][1], points[i + 1][2])
            end
        end
    end
end
