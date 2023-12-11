using Godot;
using System.Collections.Generic;

[GlobalClass]
public partial class TerrainGeneration : Node
{
    
    public Godot.Collections.Array<Vector2I> GenerateWorld(int grids, int radius){
        var grid = new Godot.Collections.Array<Vector2I>();
        Vector2I position = Vector2I.Zero;
        for (int i = 0; i < grids; i++){
            grid += CreateGrid(radius, position);

            Vector2I offset = new Vector2I(radius,0);
            position += offset;
        }
        return grid;
    }

    public Godot.Collections.Array<Vector2I> CreateGrid(int radius, Vector2I position){
        var grid = new Godot.Collections.Array<Vector2I>();
        List<Vector2I> outer = new List<Vector2I>();

        int inner = Mathf.FloorToInt(radius * .5f);
        int radiusSquaredOuter = radius * radius;
        int radiusSquaredInner = (radius - inner) * (radius - inner);

        FastNoiseLite noise = new FastNoiseLite();
        noise.Seed = (int)GD.Randi();
	    noise.Frequency *= 50;

        for (int x = -radius; x <= radius; x++)
        {
            for (int y = -radius; y <= radius; y++)
            {
                int positionx = x + position.X;
                int positiony = y + position.Y;

                int diameter = x * x + y * y;
                if (radiusSquaredInner < diameter && diameter < radiusSquaredOuter)
                {
                    float value = noise.GetNoise2D(positionx,positiony);
                    if(value >= 0){
                        outer.Add(new Vector2I(x,y));
                        grid.Add(new Vector2I(x,y));
                    }
                }
                else if(diameter < radiusSquaredInner){
                    grid.Add(new Vector2I(x,y));
                }
            }
        }
        CellularAutomata(outer,grid,2);
        return grid;
    }
    public void CellularAutomata(List<Vector2I> outer, Godot.Collections.Array<Vector2I> grid, int iterations){
        for (int i = 0; i < iterations; i++){
            foreach(Vector2I position in new List<Vector2I>(outer)){
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
                    outer.Remove(position);
                }
            }
        }
    }
}
