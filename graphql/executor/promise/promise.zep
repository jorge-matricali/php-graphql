namespace GraphQL\Executor\Promise;

use GraphQL\Utils\Utils;
/**
 * Convenience wrapper for promises represented by Promise Adapter
 */
class Promise
{
    protected adapter;
    public adoptedPromise;
    /**
     * Promise constructor.
     *
     * @param mixed $adoptedPromise
     * @param PromiseAdapter $adapter
     */
    public function __construct(adoptedPromise, <PromiseAdapter> adapter) -> void
    {
        Utils::invariant(!(adoptedPromise instanceof self), "Expecting promise from adapted system, got " . __CLASS__);
        let this->adapter = adapter;
        let this->adoptedPromise = adoptedPromise;
    }
    
    /**
     * @param callable|null $onFulfilled
     * @param callable|null $onRejected
     *
     * @return Promise
     */
    public function then(onFulfilled = null, onRejected = null) -> <Promise>
    {
        return this->adapter->then(this, onFulfilled, onRejected);
    }

}