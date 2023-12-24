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

--math modes
auto_slider = true
rotation_enabled = true
draw_lines = true
draw_points = true

--variables for the slider
a = 0
b = 1

function pesto.update(dt)
    
    --graph parameters
    points = {}
    range = {-300, 300}
    step = 1

    --slider, can be done in lots of ways
    if auto_slider then
        if a > 7 then
            b = -1
        elseif a < -7 then
            b = 1
        end

        a = a + b*0.01
    end

    --create all graph points
    for x = range[1], range[2], step do
        y = a*sin(x) + a*x/20 --y = f(x)
        y = floor(y + 0.5) --rounding the y to the closest integer, by default it's made with floor
        
        --distance with respect to a fixed point
        distance = math.sqrt((x - origin[1])^2 + (y - origin[2])^2)

        --rotation
        if rotation_enabled then
            x1, y1 = x, y
            alpha = a*distance*10
            alpha = alpha/180 * pi

            --rotation equations
            x = x1*cos(alpha) - y1*sin(alpha)
            y= x1*sin(alpha) + y1*cos(alpha)
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

    --x and y axis
    pesto.graphics.rectangle(center_x, 0, 1, screen_height)
    pesto.graphics.rectangle(0, center_y, screen_width, 1)

    --draw all points
    if draw_points then
        for _, point in pairs(points) do
            pesto.graphics.rectangle(point[1], point[2], 1, 1)
        end
    end

    --draw lines to connect points, might be not so useful
    --moving the vertex from which the line are drown to make graph better and simmetric those who are
    if draw_lines then
        for i = 1, #points - 1, 1 do
            if points[i][1] < center_x and points[i+1][1] <= center_x then
                pesto.graphics.line(points[i][1], points[i][2], points[i+1][1], points[i+1][2])
            elseif points[i][1] >= center_x and points[i+1][1] > center_x then
                pesto.graphics.line(points[i][1] + 1, points[i][2], points[i+1][1] + 1, points[i+1][2])
            end
        end
    end

end