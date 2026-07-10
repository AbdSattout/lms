package app.lms.block.controller;

import app.lms.block.dto.*;
import app.lms.block.service.BlockService;
import app.lms.security.UserPrincipal;
import app.lms.user.model.User;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/blocks")
@RequiredArgsConstructor
public class BlockController {


    private final BlockService blockService;

    @GetMapping("/{blockId}")
    public ResponseEntity<BlockPublicResponse> getBlock(

            @PathVariable Long blockId,

            @AuthenticationPrincipal
            UserPrincipal principal
    ) {

        return ResponseEntity.ok(
                blockService.getBlock(
                        blockId,
                        principal.user()
                )
        );
    }
}
