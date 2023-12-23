using Godot;
using System.Collections.Generic;

[GlobalClass]
public partial class TerrainGeneration : Node
{   
    public Godot.Collections.Array<Vector2I> GenerateWorld(int radius, Vector2I position){

        var grid = new Godot.Collections.Array<Vector2I>(CreateGrid(radius, position));
        
        return grid;
    }

    private Godot.Collections.Array<Vector2I> CreateGrid(int radius, Vector2I position){
        var grid = new Godot.Collections.Array<Vector2I>();
        List<Vector2I> outer = new List<Vector2I>();

        int inner = Mathf.FloorToInt(radius * .5f);
        int radiusSquaredOuter = radius * radius;
        int radiusSquaredInner = (radius - inner) * (radius - inner);

        FastNoiseLite noise = new FastNoiseLite{Seed = (int)GD.Randi()};
        noise.Frequency *= 10;

        for (int x = -radius; x <= radius; x++)
        {
            for (int y = -radius; y <= radius; y++)
            {
                int positionx = x + position.X;
                int positiony = y + position.Y;
                int diameter = x*x + y*y;
                if(diameter < radiusSquaredInner){
                    grid.Add(new Vector2I(positionx,positiony));
                }
                else{
                    float value = noise.GetNoise2D(positionx,positiony);
                    if(value >= 0){
                        outer.Add(new Vector2I(positionx,positiony));
                        grid.Add(new Vector2I(positionx,positiony));
                    }
                }
            }
        }
        CellularAutomata(outer,grid,2);

        foreach(Vector2I tile in new Godot.Collections.Array<Vector2I>(grid)){
            int x = tile.X - position.X;
            int y = tile.Y - position.Y;
            int diameter = x*x + y*y;
            if(diameter > radiusSquaredOuter){
                grid.Remove(tile);
            }
        }
        return grid;
    }
    private void CellularAutomata(List<Vector2I> outer, Godot.Collections.Array<Vector2I> grid, int iterations){
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
    private Godot.Collections.Array<Vector2I> CreatePassage(Godot.Collections.Array<Vector2I> grid, Vector2I gridA, Vector2I gridB){
        var passage = new Godot.Collections.Array<Vector2I>();
        int x = gridA.X;
        int y = gridA.Y;

        while(gridB.X != x){
            if(gridB.X >= x){
                x++;
                Vector2I position = new Vector2I(x,gridA.Y);
                if(!grid.Contains(position)){
                    passage.Add(position);
                }
            }
            else{
                x--;
                Vector2I position = new Vector2I(x,gridA.Y);
                if(!grid.Contains(position)){
                    passage.Add(position);
                }
            }
        }
        while(gridB.Y != y){
            if(gridB.Y >= y){
                y++;
                Vector2I position = new Vector2I(x,y);
                if(!grid.Contains(position)){
                    passage.Add(position);
                }
            }
            else{
                y--;
                Vector2I position = new Vector2I(x,y);
                if(!grid.Contains(position)){
                    passage.Add(position);
                }
            }
        }
        return passage;
    }
}