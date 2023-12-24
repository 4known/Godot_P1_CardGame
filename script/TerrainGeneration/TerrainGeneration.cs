using Godot;
using System.Collections.Generic;

[GlobalClass]
public partial class TerrainGeneration : Node
{   
    private Godot.Collections.Array<Vector2I> CreateGrid(int radius, Vector2I position){
        var grid = new Godot.Collections.Array<Vector2I>();
        List<Vector2I> outer = new List<Vector2I>();

        int inner = Mathf.FloorToInt(radius * .5f);
        int outerDistance = radius * radius;
        int innerDistance = (radius - inner) * (radius - inner);

        FastNoiseLite noise = new FastNoiseLite{Seed = (int)GD.Randi()};
        noise.Frequency *= 100;

        for (int x = -radius; x <= radius; x++)
        {
            for (int y = -radius; y <= radius; y++)
            {
                int positionx = x + position.X;
                int positiony = y + position.Y;
                int distance = x*x + y*y;
                if(distance < innerDistance){
                    grid.Add(new Vector2I(positionx,positiony));
                }
                else{
                    float value = noise.GetNoise2D(positionx,positiony);
                    float falloffValue = 0.5f * Evaluate(distance);
                    GD.Print(falloffValue);
                    value += falloffValue;
                    if(value >= 0){
                        outer.Add(new Vector2I(positionx,positiony));
                        grid.Add(new Vector2I(positionx,positiony));
                    }
                }
            }
        }
        // CellularAutomata(outer,grid,1);

        // foreach(Vector2I tile in new Godot.Collections.Array<Vector2I>(grid)){
        //     int x = tile.X - position.X;
        //     int y = tile.Y - position.Y;
        //     int distance = x*x + y*y;
        //     if(distance >= outerDistance){
        //         grid.Remove(tile);
        //     }
        // }
        return grid;
    }
    static float Evaluate(float value)
    {
        float a = 3;
        float b = 2.2f;

        float powValue = value;
        float powBValue = b - b * value;

        for (int i = 1; i < a; i++)
        {
            powValue *= value;
            powBValue *= b - b * value;
        }

        return powValue / (powValue + powBValue);
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