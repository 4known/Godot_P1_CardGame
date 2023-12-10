using Godot;
using System;
using System.Collections.Generic;

[GlobalClass]
public partial class TerrainGeneration : Node
{
    
    public Godot.Collections.Array<Vector2I> CreateGrid(int radius, Vector2I position){
        var grid = new Godot.Collections.Array<Vector2I>();
        int radiusSquaredOuter = radius * radius;
        int radiusSquaredInner = (radius - 5) * (radius - 5);

        FastNoiseLite noise = new FastNoiseLite();
        noise.Seed = (int)GD.Randi();
	    noise.Frequency *= 50;


        for (int x = -radius; x <= radius; x++)
        {
            for (int y = -radius; y <= radius; y++)
            {
                int positionx = x + position.X;
                int positiony = y + position.Y;

                float value = noise.GetNoise2D(positionx,positiony);
                int vector = x * x + y * y;
                if (radiusSquaredInner < vector && vector < radiusSquaredOuter)
                {
                    int dstX = Mathf.Abs(x/radius+1);
                    int dstY = Mathf.Abs(y/radius+1);
                    int falloff = Mathf.Max(dstX,dstY);
                    value += falloff;
                    if(value >= 1){
                        grid.Add(new Vector2I(x,y));
                    }
                }
                else if(vector < radiusSquaredInner){
                    grid.Add(new Vector2I(x,y));
                }
            }
        }
        return grid;
    }
    public void UpdateGrid(List<Vector2I> outer, Godot.Collections.Array<Vector2I> grid){
        
    }
}
// if (grid[i, j] == 1)
                // {
                //     newGrid[i, j] = neighbors == 2 || neighbors == 3 ? 1 : 0;
                // }
                // else
                // {
                //     newGrid[i, j] = neighbors == 3 ? 1 : 0;
                // }