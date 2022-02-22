import React from 'react';
import clsx from 'clsx';
import { makeStyles } from '@material-ui/core/styles';
import Checkbox from '@material-ui/core/Checkbox';

const useStyles = makeStyles({
  root: {

  },
  icon: {
    borderRadius: 3,
    width: 48,
    height: 48,

    backgroundImage: 'linear-gradient(white, white)',
    '$root.Mui-focusVisible &': {
      outline: '2px auto #fffff',
      outlineOffset: 5,
    },
    'input:hover ~ &': {
      backgroundColor: '#ebf1f5',
    },
    'input:disabled ~ &': {
      boxShadow: 'none',
      background: 'rgba(206,217,224,.5)',
    },
  },
  checkedIcon: {
    '&:before': {
      display: 'block',
      width: 48,
      height: 48,
        backgroundImage:
        'url(data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAADAAAAAwCAYAAABXAvmHAAADlElEQVRoQ+2Zx8tVMRDFf58re1dUXKooYu8FsXdR8Vv4B7oUxIa99y6CouJWxN7rQuRIAo/ru8kkuQ958LK9k5lzMpOZydw+unz1dTl+egT+twd7HugWD2wC9gF3gH7gS4eAjwAOADOBvcC5mB1LCG0ADgEDnbKrwBbgU0x54veRwElgkdv3DdgeIxEjsA44DAyqgLkOyCtNkRgFnAIWVOyIxDbgfN1hhAisBo4Cg2s23wQ2Ah8TT7oqPho4Dcyr0SMSW4EL7b6HCLwBxkTA3XYk3meSkH6BnxvZ/xKYkErgGrDUAOwesB54Z5BtFRkLnAFmG/YphNakEtDpKC7rXNuq774j8dYARiLjHPhZBvlgqMYusS6XXDzfYOiBI/E6IjseOOtSZUxtNFnECMiA0ps8sTBmDXgIrAVe1cgqjgV+hkGX0vVm4HNI1kJA+1VglKMXGww/ciR08VrXRAd+ukHHZVdrogXTSkA2hwMnjBf7sSPxwoGd5ArSNAP4iy73R8FLVwoByQ8DjgPLDUCeuswhG2oJphr2KNuo+n41yP4VSSWgPUOBY8BKg5FnTmaKQVZ3YwegwmVeOQQ8CVXpVWZLYUEliZ3A91R9uQRkZwhwBFDLUbJ0r3YBP3KUlBCQPfVJavaUOnOWQnE38DNnc+4dqNpSp3oQUNudshSCe0rAN0VAevRWEAl1p5al0BP4XxbhkExpCHndKnSK5SVGQDcc2eL3RBMEVOBUpa3gPcdon2M5jFICueA9NrXs6neyPVFCoBR8Kwk9T4NNW503cgmk9EWWSJAnskjkEBB49UPLDMh0WWXD0sWa2ueqzVQCauaUbSzg/UtKNq2t+BV3J0ydaGodyAHvJxZKs+p3/Mwn5LwkElYPpLTRt1xVro5bUl52jT5oUsBrzKKW4kPNEaeQuOTmQcFwinlAvb8u7ArDhY2B9ypEQoOC6hSunQmR0Biz9oETIpACXkNfzYbqTr4KLmXaoSemJnNtSYQIKHNYOsy7DnzqdC6FhDpXPTX/WSECGo1oABVaueC9zthc1Ms9ByanEtAoT8yrk2mvJ3ekWMURI6HQUQgplJI8IOG68XpT4Fs9oTlpdcgbnExbC5kup35weE9oDipiqcPcWCLTLFYk5jjB6L8BKwHJicR+4Ilzp3WIGwNd/S4SClsNwPRia+QXkzcyAPidiqjT8rFC1mn7xfp7BIqPsFBBzwOFB1i8/Q8Iia8xBzQhQgAAAABJRU5ErkJggg==)',
      content: '""',
     },
    'input:hover ~ &': {
      backgroundColor: '#fffff',
    },
  },
});

export default function CustomizedCheckbox(props) {
  const classes = useStyles();
  return (
      <Checkbox
        className={classes.root}
        disableRipple
        color="default"
        checkedIcon={<span className={clsx(classes.icon, classes.checkedIcon)} />}
        icon={<span className={classes.icon} />}
        inputProps={{ 'aria-label': 'decorative checkbox' }}
        {...props}
        onChange={props.onChange}
        name={props.name}
        value={props.value}
      />
    )
  }
