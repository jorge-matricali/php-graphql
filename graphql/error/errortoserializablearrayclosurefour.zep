namespace GraphQL\Error;

class ErrortoSerializableArrayClosureFour
{

    public function __construct()
    {
        
    }

    public function __invoke(SourceLocation loc)
    {
    return loc->toSerializableArray();
    }
}
    