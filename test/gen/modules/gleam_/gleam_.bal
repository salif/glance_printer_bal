public type Ignore ();

public type MainReturn error?;

public function mainReturn(any r) returns MainReturn {
    return ();
}

public function divideInt(int a, int b) returns int {
    if (b == 0) {
        return 0;
    } else {
        return a / b;
    }
}

public function remainderInt(int a, int b) returns int {
    if (b == 0) {
        return 0;
    } else {
        return a % b;
    }
}

public function divideFloat(float a, float b) returns float {
    if (b == 0.0) {
        return 0.0;
    } else {
        return a / b;
    }
}
