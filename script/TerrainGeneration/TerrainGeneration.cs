using Godot;
using System;
using System.Collections.Generic;

[GlobalClass]
public partial class TerrainGeneration : Node
{
    
    public Godot.Collections.Array<Vector2I> CreateGrid(int radius, Vector2I position){
        var grid = new Godot.Collections.Array<Vector2I>();
        List<Vector2I> outer = new List<Vector2I>();

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
                    if(value >= 0){
                        outer.Add(new Vector2I(x,y));
                        grid.Add(new Vector2I(x,y));
                    }
                }
                else if(vector < radiusSquaredInner){
                    grid.Add(new Vector2I(x,y));
                }
            }
        }
        UpdateGrid(outer,grid);
        return grid;
    }
    public void UpdateGrid(List<Vector2I> outer, Godot.Collections.Array<Vector2I> grid){
        foreach(Vector2I position in outer){
            int neighbors = 0;
            for (int x = -1; x <= 1; x++){
                for (int y = -1; y <= 1; y++){
                    if (x == 0 && y == 0)
					    continue;
                    
                    if(grid.Contains(new Vector2I(x + position.X,y + position.Y))){
                        neighbors++;
                    }
                }
            }
            if(neighbors <= 3){
                grid.Remove(position);
            }
        }
    }
}
