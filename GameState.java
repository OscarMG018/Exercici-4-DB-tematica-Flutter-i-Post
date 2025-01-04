
public abstract class RealTimeData {
    public LocalDateTime lastUpdate;
    public abstract void updateData();
}

public class GameState extends RealTimeData {
    public int health;
    public int mana;
    public int hpregen;
    public int manaregen;

    public void updateData() {
        if (lastUpdate == null) {
            lastUpdate = LocalDateTime.now();
            return;
        }
        LocalDateTime now = LocalDateTime.now();
        //set game state
        health = hpregen * (now.getSecond() - lastUpdate.getSecond());
        mana = manaregen * (now.getSecond() - lastUpdate.getSecond());
        
        lastUpdate = now;
    }
    
    public int getHealth() {
        updateData();
        return health;
    }

    public int getMana() {
        updateData();
        return mana;
    }
}
