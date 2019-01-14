package com.jlupin.bnk.demo.common.util;

public class ZamulatorImpl implements Zamulator {

    @Override
    public boolean zamul(long milis) {
        long objectiveTime = System.currentTimeMillis() + milis;
        while (System.currentTimeMillis() < objectiveTime) ;
        return false;
    }
}
