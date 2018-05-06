namespace GraphQL\Executor\Promise\Adapter;

class SyncPromiseenqueueWaitingPromisesClosureTwo
{
    private descriptor;

    public function __construct(descriptor)
    {
                let this->descriptor = descriptor;

    }

    public function __invoke()
    {
    tmpListPromiseOnFulfilledOnRejected;
    if this->state === self::FULFILLED {
        try {
            promise->resolve( onFulfilled ? {onFulfilled}(this->result)  : this->result);
        } catch \Exception, e {
            promise->reject(e);
        } catch \Throwable, e {
            promise->reject(e);
        }
    } else {
        if this->state === self::REJECTED {
            try {
                if onRejected {
                    promise->resolve({onRejected}(this->result));
                } else {
                    promise->reject(this->result);
                }
            } catch \Exception, e {
                promise->reject(e);
            } catch \Throwable, e {
                promise->reject(e);
            }
        }
    }
    }
}
    