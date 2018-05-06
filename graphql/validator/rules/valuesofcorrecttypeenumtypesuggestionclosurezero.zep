namespace GraphQL\Validator\Rules;

class ValuesOfCorrectTypeenumTypeSuggestionClosureZero
{

    public function __construct()
    {
        
    }

    public function __invoke(EnumValueDefinition value)
    {
    return value->name;
    }
}
    