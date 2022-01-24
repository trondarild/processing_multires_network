import numpy as np
som = [2,2] #[3,5]
map = [2,1] #[7,11]
rf =  [3,2]#[5,7]
som_t = som[0] * som[1] # filterbanksize
map_t = map[0] * map[1] # filterlocations
rf_t = rf[0] * rf[1] # filtersize

activ_tensor = np.linspace(0, 1, map_t*som_t) # np.ones((map_t, som_t)) * 0.1
activ_tensor.shape = (map_t, som_t)
w_tensor = 2*np.linspace(0, 1, som_t*rf_t)
w_tensor.shape = (som_t, rf_t) #np.ones((som_t, rf_t)) * 0.2
inh_mask = 3*np.linspace(0,1, som_t*som_t)
inh_mask.shape = (som_t, som_t)
bu_inp = 4*np.linspace(0, 1, map_t*rf_t) # np.ones((map_t, rf_t)) * 0.3
bu_inp.shape = (map_t, rf_t)
alpha = 0.001

def test():


    a_rep = np.tile(np.expand_dims(activ_tensor, axis=0), [som_t,1, 1])
    print()
    print('a_rep')
    print(a_rep.shape)
    # print(a_rep)
    #print(np.ravel(a_rep))
    #w_rep = np.tile(np.expand_dims(w_tensor, axis=0), [som_t, 1, 1])
    w_rep = np.expand_dims(w_tensor, axis=0)
    print(w_rep.shape)
    w_rep = np.transpose(w_rep, (1,0,2))
    print('w_rep 1')
    #print(np.ravel(w_rep))
    print(w_rep.shape)
    #w_rep = np.tile(np.expand_dims(w_rep, axis=0), [map_t, 1, 1, 1])
    w_rep = np.tile(w_rep, [1, map_t, som_t])
    print('w_rep 2')
    #print(np.ravel(w_rep))
    print(w_rep.shape)
    mask_rep = np.expand_dims(inh_mask, axis=0)
    mask_rep = np.transpose(mask_rep, (1,0,2))
    mask_rep = np.tile(mask_rep, [1, map_t, 1])
    # print()
    print('mask_rep')
    # print(mask_rep)
    print(mask_rep.shape)
    m_a = np.multiply(mask_rep, a_rep)
    print()
    print('m_a')
    print(m_a.shape)
    #print(np.ravel(m_a) == np.multiply(np.ravel(mask_rep), np.ravel(a_rep)))
    #m_a_r = np.tile(np.expand_dims(m_a, axis=3), [1, 1, 1, rf_t])
    m_a_r = np.repeat(m_a, rf_t, axis=2)
    print()
    print('m_a_r')
    print(m_a_r.shape)
    w_m_a = np.multiply(w_rep, m_a_r)
    print()
    print('w_m_a')
    print(w_m_a.shape)
    inh_buf_vec = np.sum(w_m_a, axis=0)
    print()
    print('inh_buf_vec')
    print(inh_buf_vec.shape)
    
    #inp_rep = np.expand_dims(bu_inp, axis=0)
    inp_rep  = np.tile(bu_inp, [1, som_t])
    print()
    print('inp_rep')
    print(inp_rep.shape)
    
    delta_buffer = inp_rep - inh_buf_vec
    print()
    print('delta_buffer')
    print(delta_buffer.shape)
    delta_buffer = np.expand_dims(delta_buffer, axis=0)
    delta_buffer.shape = (som_t, map_t, rf_t)
    print()
    print('delta_buffer')
    print(delta_buffer.shape)
    
    a_rep = np.expand_dims(activ_tensor, axis=0)
    a_rep = np.transpose(a_rep, (2,1,0))
    a_rep = np.tile(a_rep, [1, 1, rf_t])
    print()
    print('a_rep')
    print(a_rep.shape)
    
    dw = alpha * (delta_buffer * a_rep)
    print()
    print('dw')
    print(dw.shape)

    w_acc = np.sum(dw, axis=1)
    print()
    print('w_acc')
    print(w_acc.shape)
    print(w_acc)
    return w_acc

def test_vs_stridetile():


    a_rep = np.tile(np.expand_dims(activ_tensor, axis=0), [som_t,1, 1])
    a_rep_st = stride_tile(times=som_t, stride=map_t*som_t, a = np.ravel(activ_tensor))

    print()
    print('a_rep')
    #print(np.ravel(a_rep)==a_rep_st) 
    #print(a_rep_st)
    # print(a_rep)
    #print(np.ravel(a_rep))
    #w_rep = np.tile(np.expand_dims(w_tensor, axis=0), [som_t, 1, 1])
    w_rep = np.expand_dims(w_tensor, axis=0)
    print(w_rep.shape)
    w_rep = np.transpose(w_rep, (1,0,2))
    print('w_rep 1')
    #print(np.ravel(w_rep))
    print(w_rep.shape)
    #w_rep = np.tile(np.expand_dims(w_rep, axis=0), [map_t, 1, 1, 1])
    w_rep = np.tile(w_rep, [1, map_t, som_t])
    print('w_rep 2')
    #print(np.ravel(w_rep))
    print(w_rep.shape)
    w_rep_st = stride_tile(times=map_t*som_t, stride=som_t*rf_t, a=w_tensor)
    print(np.ravel(w_rep))
    print(w_rep_st)
    print(np.ravel(w_rep)==w_rep_st)

    mask_rep = np.expand_dims(inh_mask, axis=0)
    mask_rep = np.transpose(mask_rep, (1,0,2))
    mask_rep = np.tile(mask_rep, [1, map_t, 1])
    # print()
    print('mask_rep')
    # print(mask_rep)
    print(mask_rep.shape)
    m_a = np.multiply(mask_rep, a_rep)
    print()
    print('m_a')
    print(m_a.shape)
    #print(np.ravel(m_a) == np.multiply(np.ravel(mask_rep), np.ravel(a_rep)))
    #m_a_r = np.tile(np.expand_dims(m_a, axis=3), [1, 1, 1, rf_t])
    m_a_r = np.repeat(m_a, rf_t, axis=2)
    print()
    print('m_a_r')
    print(m_a_r.shape)
    w_m_a = np.multiply(w_rep, m_a_r)
    print()
    print('w_m_a')
    print(w_m_a.shape)
    inh_buf_vec = np.sum(w_m_a, axis=0)
    print()
    print('inh_buf_vec')
    print(inh_buf_vec.shape)
    
    #inp_rep = np.expand_dims(bu_inp, axis=0)
    inp_rep  = np.tile(bu_inp, [1, som_t])
    print()
    print('inp_rep')
    print(inp_rep.shape)
    
    delta_buffer = inp_rep - inh_buf_vec
    print()
    print('delta_buffer')
    print(delta_buffer.shape)
    delta_buffer = np.expand_dims(delta_buffer, axis=0)
    delta_buffer.shape = (som_t, map_t, rf_t)
    print()
    print('delta_buffer')
    print(delta_buffer.shape)
    
    a_rep = np.expand_dims(activ_tensor, axis=0)
    a_rep = np.transpose(a_rep, (2,1,0))
    a_rep = np.tile(a_rep, [1, 1, rf_t])
    print()
    print('a_rep')
    print(a_rep.shape)
    
    dw = alpha * (delta_buffer * a_rep)
    print()
    print('dw')
    print(dw.shape)

    w_acc = np.sum(dw, axis=1)
    print()
    print('w_acc')
    print(w_acc.shape)
    #print(w_acc)
    return w_acc

def tst_wrep():
    w_rep = np.expand_dims(w_tensor, axis=0)
    print(w_rep.shape)
    w_rep = np.transpose(w_rep, (1,0,2))
    print('w_rep 1')
    #print(np.ravel(w_rep))
    print(w_rep.shape)
    #w_rep = np.tile(np.expand_dims(w_rep, axis=0), [map_t, 1, 1, 1])
    w_rep = np.tile(w_rep, [1, map_t, 1])
    print(np.ravel(w_tensor))
    print()
    print(np.ravel(w_rep))
    print()
    w_rep = np.tile(w_rep, [1, 1, som_t])
    print(np.ravel(w_rep))
    print()

    w_rep_st = stride_tile(times=map_t, stride=rf_t, a=np.ravel(w_tensor))
    w_rep_st = stride_tile(times=som_t, stride=rf_t, a=np.ravel(w_rep_st))
    print(w_rep_st)
    print(np.ravel(w_rep) == w_rep_st)

def tst_mr():
    mask_rep = np.expand_dims(inh_mask, axis=0)
    mask_rep = np.transpose(mask_rep, (1,0,2))
    mask_rep = np.tile(mask_rep, [1, map_t, 1])
    # print()
    print('mask_rep')
    print(inh_mask.shape)
    print(np.ravel(inh_mask))
    print()
    print(np.ravel(mask_rep))   

    mask_rep_st = stride_tile(times=map_t, stride=som_t, a=np.ravel(inh_mask))
    print()
    print(mask_rep_st)
    print(np.ravel(mask_rep)==mask_rep_st)

def tst_ar():
    a_rep = np.tile(np.expand_dims(activ_tensor, axis=0), [som_t,1, 1])
    print()
    print('a_rep')
    print(a_rep.shape)
    print()
    print(np.ravel(activ_tensor))
    print()
    print(np.ravel(a_rep))

    a_rep_st = stride_tile(times=som_t, stride=som_t*map_t, a=np.ravel(activ_tensor))
    print()
    print(a_rep_st)
    print(np.ravel(a_rep)==a_rep_st)

def tst_mar():
    a_rep = np.tile(np.expand_dims(activ_tensor, axis=0), [som_t,1, 1])
    mask_rep = np.expand_dims(inh_mask, axis=0)
    mask_rep = np.transpose(mask_rep, (1,0,2))
    mask_rep = np.tile(mask_rep, [1, map_t, 1])
    # print()
    print('mask_rep')
    # print(mask_rep)
    print(mask_rep.shape)
    m_a = np.multiply(mask_rep, a_rep)
    print()
    print('m_a')
    print(np.ravel(m_a))
    print()
    #print(np.ravel(m_a) == np.multiply(np.ravel(mask_rep), np.ravel(a_rep)))
    #m_a_r = np.tile(np.expand_dims(m_a, axis=3), [1, 1, 1, rf_t])
    m_a_r = np.repeat(m_a, rf_t, axis=2)
    print(np.ravel(m_a_r))

    m_a_r_st = stride_tile(times=rf_t, stride=1, a=np.ravel(m_a))
    print()
    print(m_a_r_st)
    print(np.ravel(m_a_r)==m_a_r_st)


def test_forloop():
    return 0

def test_stridetile():
    a = np.linspace(1,12,12)
    st = [2,3,4,6,12]
    for s in st:
        b = stride_tile(2,s, a)
        print(b)


def stride_tile(times, stride, a):
    retval = np.zeros(len(a) * times)
    divs = len(a) // stride

    retstart = 0
    for i in range(divs):
        for t in range(times):
            retval[retstart:retstart+stride] = a[i*stride:i*stride+stride]
            retstart += stride
    return retval

#w_elem_mult = test()
#test_stridetile()
#test_vs_stridetile()
#tst_wrep()
#tst_mr()
#tst_ar()
tst_mar()