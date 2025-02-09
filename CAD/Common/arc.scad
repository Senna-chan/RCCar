radius = 5;
thickness = 1;
angle = 130;

/*
radius: Outside radius of the arc
thickness: Thickness between the inside and outside of the radius
angle: The angle of the arc, anywhere between 0 and 360.
*/
module arc(radius, thickness, angle)
{
    intersection()
    {
        union()
        {
            rights = floor(angle / 90);
            remain = angle - rights * 90;
            if (angle > 90)
            {
                for (i = [0:rights - 1])
                {
                    rotate(i * 90 - (rights - 1) * 90 / 2)
                    {
                        polygon([
                            [ 0, 0 ], [ radius + thickness, (radius + thickness) * tan(90 / 2) ],
                            [ radius + thickness, -(radius + thickness) * tan(90 / 2) ]
                        ]);
                    }
                }
                rotate(-(rights) * 90 / 2) polygon([
                    [ 0, 0 ], [ radius + thickness, 0 ], [ radius + thickness, -(radius + thickness) * tan(remain / 2) ]
                ]);
                rotate((rights) * 90 / 2) polygon([
                    [ 0, 0 ], [ radius + thickness, (radius + thickness) * tan(remain / 2) ], [ radius + thickness, 0 ]
                ]);
            }
            else
            {
                polygon([
                    [ 0, 0 ], [ radius + thickness, (radius + thickness) * tan(angle / 2) ],
                    [ radius + thickness, -(radius + thickness) * tan(angle / 2) ]
                ]);
            }
        }
        difference()
        {
            circle(radius + thickness);
            circle(radius);
        }
    }
}

arc(radius = radius, thickness = thickness, angle = angle);