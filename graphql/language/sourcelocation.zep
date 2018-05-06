namespace GraphQL\Language;

class SourceLocation implements \JsonSerializable
{
    public line;
    public column;
    public function __construct(line, col) -> void
    {
        let this->line = line;
        let this->column = col;
    }
    
    /**
     * @return array
     */
    public function toArray() -> array
    {
        var tmpArray880d90c4281fef2dd7a345a4291c26fe;
    
        let tmpArray880d90c4281fef2dd7a345a4291c26fe = ["line" : this->line, "column" : this->column];
        return tmpArray880d90c4281fef2dd7a345a4291c26fe;
    }
    
    /**
     * @return array
     */
    public function toSerializableArray() -> array
    {
        return this->toArray();
    }
    
    /**
     * Specify data which should be serialized to JSON
     * @link http://php.net/manual/en/jsonserializable.jsonserialize.php
     * @return mixed data which can be serialized by <b>json_encode</b>,
     * which is a value of any type other than a resource.
     * @since 5.4.0
     */
    function jsonSerialize()
    {
        return this->toSerializableArray();
    }

}