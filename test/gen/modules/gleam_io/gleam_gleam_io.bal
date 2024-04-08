import ballerina/io;

public function println(string str) returns () {
    io:println(str);
    return ();
}

public function debug(any term) returns any {
    io:fprintln(io:stderr, term);
    return term;
}
